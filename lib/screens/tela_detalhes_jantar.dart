import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';

class TelaDetalhesJantar extends StatefulWidget {
  final Cardapio refeicao;

  const TelaDetalhesJantar({super.key, required this.refeicao});

  @override
  State<TelaDetalhesJantar> createState() => _TelaDetalhesJantarState();
}

class _TelaDetalhesJantarState extends State<TelaDetalhesJantar> {
  late Future<LatLng?> _coordenadasFuture;

  @override
  void initState() {
    super.initState();
    _coordenadasFuture = _buscarCoordenadasPrecisa();
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
          String localidade = dadosCep['localidade'];
          String uf = dadosCep['uf'];
          String numero = widget.refeicao.nuCasa;
          queryBusca = "$logradouro, $numero, $localidade - $uf, Brasil";
        } else {
          queryBusca = "${widget.refeicao.nuCep}, ${widget.refeicao.nuCasa}, Brasil";
        }
      } else {
        queryBusca = "${widget.refeicao.nuCep}, ${widget.refeicao.nuCasa}, Brasil";
      }

      final queryEncoded = Uri.encodeComponent(queryBusca);
      final urlNominatim = Uri.parse("https://nominatim.openstreetmap.org/search?q=$queryEncoded&format=json&limit=1");

      final responseMap = await http.get(urlNominatim, headers: {'User-Agent': 'com.example.dinneer'});

      if (responseMap.statusCode == 200) {
        final dadosMap = jsonDecode(responseMap.body);
        if (dadosMap is List && dadosMap.isNotEmpty) {
          final lat = double.parse(dadosMap[0]['lat']);
          final lon = double.parse(dadosMap[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar coordenadas: $e");
    }
    return null;
  }

  Future<void> _realizarReserva(int idEncontro, int dependentes) async {
    try {
      final idLogadoStr = await SessionService.pegarUsuarioId();
      if (idLogadoStr == null) throw Exception("Faça login novamente.");
      final int idLogado = int.parse(idLogadoStr);

      final resposta = await EncontroService.reservar(idLogado, idEncontro, dependentes);
      
      if (resposta != null && resposta['dados'] != null) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reserva realizada com sucesso! 🎉"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Retorna true para atualizar a Home se quiser
        }
      } else {
        String erro = resposta?['Mensagem'] ?? "Erro desconhecido.";
        throw Exception(erro);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Atenção: $e"), backgroundColor: Colors.orange));
      }
    }
  }

  void _mostrarModalAgendamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final TextEditingController dependentesController = TextEditingController();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Agendamento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("Quantas pessoas irão jantar com você?"),
                const SizedBox(height: 8),
                TextField(
                  controller: dependentesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Número de convidados extras (0 se for só você)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final int dependentes = int.tryParse(dependentesController.text) ?? 0;
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Processando reserva...")));
                      _realizarReserva(widget.refeicao.idEncontro, dependentes);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("CONFIRMAR RESERVA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    // --- LÓGICA DE LOTAÇÃO ---
    final bool estaLotado = widget.refeicao.nuConvidadosConfirmados >= widget.refeicao.nuMaxConvidados;
    // -------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // Se estiver lotado, o botão não funciona (null)
          onPressed: estaLotado ? null : () => _mostrarModalAgendamento(context),
          style: ElevatedButton.styleFrom(
            // Cor muda se estiver lotado
            backgroundColor: estaLotado ? Colors.grey : Colors.black, 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: Text(
            estaLotado ? 'JANTAR LOTADO' : 'QUERO PARTICIPAR', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: AppBarClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: (widget.refeicao.urlFoto != null && widget.refeicao.urlFoto!.isNotEmpty)
                        ? DecorationImage(image: NetworkImage(widget.refeicao.urlFoto!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (widget.refeicao.urlFoto == null || widget.refeicao.urlFoto!.isEmpty)
                      ? const Icon(Icons.restaurant, size: 100, color: Colors.white)
                      : null,
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.refeicao.nmCardapio, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.refeicao.precoFormatado, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 16),
                  _buildInfoUsuario(),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text("Sobre o Jantar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(widget.refeicao.dsCardapio.isNotEmpty ? widget.refeicao.dsCardapio : "Sem descrição.", style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 24),
                  _buildDetalhesAdicionais(),
                  const SizedBox(height: 24),
                  const Text("Localização", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildMapa(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapa() {
    return FutureBuilder<LatLng?>(
      future: _coordenadasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 250, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)), child: const Center(child: CircularProgressIndicator(color: Colors.black)));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(height: 250, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_off, color: Colors.grey, size: 40), const SizedBox(height: 8), Text("Endereço não localizado: ${widget.refeicao.nuCep}", style: const TextStyle(color: Colors.grey))]));
        }
        final coordenadas = snapshot.data!;
        return Container(
          height: 250,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(initialCenter: coordenadas, initialZoom: 16.0, interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate)),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.dinneer'),
                MarkerLayer(markers: [Marker(point: coordenadas, width: 80, height: 80, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoUsuario() {
    return Row(
      children: [
        CircleAvatar(radius: 26, backgroundColor: Colors.grey[300], backgroundImage: (widget.refeicao.urlFotoAnfitriao != null && widget.refeicao.urlFotoAnfitriao!.isNotEmpty) ? NetworkImage(widget.refeicao.urlFotoAnfitriao!) : null, child: (widget.refeicao.urlFotoAnfitriao == null || widget.refeicao.urlFotoAnfitriao!.isEmpty) ? const Icon(Icons.person, color: Colors.white) : null),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Anfitrião", style: TextStyle(fontSize: 12, color: Colors.grey[600])), Text(widget.refeicao.nmUsuarioAnfitriao, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16)])]),
      ],
    );
  }

  Widget _buildDetalhesAdicionais() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildInfoRow(Icons.calendar_today, widget.refeicao.dataFormatada), Container(width: 1, height: 24, color: Colors.grey[300]), _buildInfoRow(Icons.people_alt_outlined, '${widget.refeicao.nuConvidadosConfirmados}/${widget.refeicao.nuMaxConvidados} vagas')]));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 20, color: Colors.black87), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))]);
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const curveHeight = 40.0;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - curveHeight);
    path.quadraticBezierTo(size.width / 2, size.height, 0, size.height - curveHeight);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}