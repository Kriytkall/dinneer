import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' hide Path;
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/service/refeicao/cardapioService.dart';
import 'components/jantar_app_bar.dart';
import 'components/jantar_info_header.dart';
import 'components/anfitriao_info.dart';
import 'components/jantar_descricao.dart';
import 'components/jantar_detalhes_card.dart';
import 'components/mapa_localizacao.dart';
import 'components/botoes_acao.dart';

class TelaDetalhesJantar extends StatefulWidget {
  final Cardapio refeicao;

  const TelaDetalhesJantar({super.key, required this.refeicao});

  @override
  State<TelaDetalhesJantar> createState() => _TelaDetalhesJantarState();
}

class _TelaDetalhesJantarState extends State<TelaDetalhesJantar> {
  late Future<LatLng?> _coordenadasFuture;
  int? _idUsuarioLogado;
  bool _carregandoUsuario = true;
  bool _jaReservei = false;
  String? _statusReserva;
  String _enderecoLegivel = "";

  @override
  void initState() {
    super.initState();
    _enderecoLegivel =
        "CEP: ${widget.refeicao.nuCep}, Nº ${widget.refeicao.nuCasa}";
    _coordenadasFuture = _buscarCoordenadasPrecisa();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final idStr = await SessionService.pegarUsuarioId();
    if (mounted) {
      setState(() {
        _idUsuarioLogado = idStr != null ? int.tryParse(idStr) : null;
      });

      if (_idUsuarioLogado != null) {
        final dadosReserva = await EncontroService.verificarSeJaReservei(
          _idUsuarioLogado!,
          widget.refeicao.idEncontro,
        );

        bool reservou = false;
        String? status;

        if (dadosReserva is Map) {
          reservou = dadosReserva['ja_reservou'] ?? false;
          status = dadosReserva['status'];
        } else if (dadosReserva is bool) {
          reservou = dadosReserva;
        }

        if (mounted) {
          setState(() {
            _jaReservei = reservou;
            _statusReserva = status;
            _carregandoUsuario = false;
          });
        }
      } else {
        if (mounted) setState(() => _carregandoUsuario = false);
      }
    }
  }

  Future<LatLng?> _buscarCoordenadasPrecisa() async {
    try {
      String cepLimpo = widget.refeicao.nuCep.replaceAll(RegExp(r'[^0-9]'), '');
      final urlViaCep = Uri.parse("https://viacep.com.br/ws/$cepLimpo/json/");
      final responseCep = await http.get(urlViaCep);

      String queryBusca;

      if (responseCep.statusCode == 200) {
        final dadosCep = jsonDecode(responseCep.body);
        if (dadosCep['erro'] != true) {
          String logradouro = dadosCep['logradouro'];
          String bairro = dadosCep['bairro'];
          String localidade = dadosCep['localidade'];
          String uf = dadosCep['uf'];
          String numero = widget.refeicao.nuCasa;

          if (mounted) {
            setState(() {
              _enderecoLegivel =
                  "$logradouro, $numero\n$bairro - $localidade/$uf";
            });
          }

          queryBusca = "$logradouro, $numero, $localidade - $uf, Brasil";
        } else {
          queryBusca =
              "${widget.refeicao.nuCep}, ${widget.refeicao.nuCasa}, Brasil";
        }
      } else {
        queryBusca =
            "${widget.refeicao.nuCep}, ${widget.refeicao.nuCasa}, Brasil";
      }

      final queryEncoded = Uri.encodeComponent(queryBusca);
      final urlNominatim = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$queryEncoded&format=json&limit=1",
      );

      final responseMap = await http.get(
        urlNominatim,
        headers: {'User-Agent': 'com.example.dinneer'},
      );

      if (responseMap.statusCode == 200) {
        final dadosMap = jsonDecode(responseMap.body);
        if (dadosMap is List && dadosMap.isNotEmpty) {
          final lat = double.parse(dadosMap[0]['lat']);
          final lon = double.parse(dadosMap[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint("Erro: $e");
    }
    return null;
  }

  Future<void> _realizarReserva(int dependentes) async {
    try {
      if (_idUsuarioLogado == null) throw Exception("Erro de sessão.");

      final resposta = await EncontroService.reservar(
        _idUsuarioLogado!,
        widget.refeicao.idEncontro,
        dependentes,
      );

      if (resposta != null && resposta['dados'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Solicitação enviada com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
          _carregarDadosIniciais();
          Navigator.pop(context, true);
        }
      } else {
        String erro = resposta?['Mensagem'] ?? "Erro desconhecido.";
        throw Exception(erro);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Atenção: $e"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _cancelarMinhaReserva() async {
    try {
      await EncontroService.cancelarReserva(
        _idUsuarioLogado!,
        widget.refeicao.idEncontro,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reserva cancelada."),
            backgroundColor: Colors.orange,
          ),
        );
        _carregarDadosIniciais();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao cancelar."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletarJantar() async {
    try {
      await CardapioService.deleteJantar(widget.refeicao.idRefeicao);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Jantar cancelado.")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao excluir."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancelar Jantar?"),
        content: const Text(
          "Isso removerá o jantar e cancelará todas as reservas. Tem certeza?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deletarJantar();
            },
            child: const Text(
              "Sim, Cancelar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarCancelamentoReserva() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancelar Reserva?"),
        content: const Text("Você perderá seu lugar neste jantar."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Voltar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _cancelarMinhaReserva();
            },
            child: const Text(
              "Confirmar Cancelamento",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModalAgendamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController dependentesController =
            TextEditingController();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Agendamento",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text("Quantas pessoas irão jantar com você?"),
                const SizedBox(height: 8),
                TextField(
                  controller: dependentesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Número de convidados extras (0 se for só você)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final int dependentes =
                          int.tryParse(dependentesController.text) ?? 0;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enviando solicitação..."),
                        ),
                      );
                      _realizarReserva(dependentes);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "ENVIAR SOLICITAÇÃO",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool estaLotado =
        widget.refeicao.nuConvidadosConfirmados >=
        widget.refeicao.nuMaxConvidados;
    final bool souOAnfitriao =
        _idUsuarioLogado != null &&
        _idUsuarioLogado == widget.refeicao.idUsuario;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _carregandoUsuario
          ? const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: BotoesAcao(
                souOAnfitriao: souOAnfitriao,
                estaLotado: estaLotado,
                jaReservei: _jaReservei,
                statusReserva: _statusReserva,
                refeicao: widget.refeicao,
                idUsuarioLogado: _idUsuarioLogado,
                onConfirmarExclusao: _confirmarExclusao,
                onConfirmarCancelamentoReserva: _confirmarCancelamentoReserva,
                onMostrarModalAgendamento: _mostrarModalAgendamento,
              ),
            ),
      body: CustomScrollView(
        slivers: [
          JantarAppBar(refeicao: widget.refeicao),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JantarInfoHeader(refeicao: widget.refeicao),
                  const SizedBox(height: 16),
                  AnfitriaoInfo(refeicao: widget.refeicao),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  JantarDescricao(descricao: widget.refeicao.dsCardapio),
                  const SizedBox(height: 24),
                  JantarDetalhesCard(refeicao: widget.refeicao),
                  const SizedBox(height: 24),
                  const Text(
                    "Localização",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _enderecoLegivel,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MapaLocalizacao(
                    coordenadasFuture: _coordenadasFuture,
                    cep: widget.refeicao.nuCep,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
