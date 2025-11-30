import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/campo_de_texto.dart';
import '../service/refeicao/cardapioService.dart';

class TelaCriarJantar extends StatefulWidget {
  final String idUsuario;

  const TelaCriarJantar({super.key, required this.idUsuario});

  @override
  State<TelaCriarJantar> createState() => _TelaCriarJantarState();
}

class _TelaCriarJantarState extends State<TelaCriarJantar> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _vagasController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  File? _imagemSelecionada;
  bool _estaCarregando = false;

  Future<void> _escolherImagem() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Padronização: Qualidade 80%
        maxWidth: 1080,   // Padronização: Largura 1080px
      );
      if (imagem != null) {
        setState(() {
          _imagemSelecionada = File(imagem.path);
        });
      }
    } catch (e) {
      debugPrint("Erro ao escolher imagem: $e");
    }
  }

  Future<String?> _uploadImagemFirebase(File imagem) async {
    try {
      String nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('jantares/$nomeArquivo.jpg');
      UploadTask task = ref.putFile(imagem);
      TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Erro no upload Firebase: $e");
      return null;
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (data != null) setState(() => _dataSelecionada = data);
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (hora != null) setState(() => _horaSelecionada = hora);
  }

  void _criarJantar() async {
    if (_tituloController.text.isEmpty || _precoController.text.isEmpty || _dataSelecionada == null || _horaSelecionada == null) {
      _mostrarErro("Preencha todos os campos.");
      return;
    }
    if (_imagemSelecionada == null) {
      _mostrarErro("Selecione uma foto para o prato.");
      return;
    }

    setState(() => _estaCarregando = true);

    String? urlFoto = await _uploadImagemFirebase(_imagemSelecionada!);
    if (urlFoto == null) {
      _mostrarErro("Erro ao enviar imagem.");
      setState(() => _estaCarregando = false);
      return;
    }

    final dataHora = DateTime(_dataSelecionada!.year, _dataSelecionada!.month, _dataSelecionada!.day, _horaSelecionada!.hour, _horaSelecionada!.minute);

    final dados = {
      'id_usuario': widget.idUsuario.toString(),
      'nm_cardapio': _tituloController.text,
      'ds_cardapio': _descricaoController.text,
      'preco_refeicao': _precoController.text.replaceAll(',', '.'),
      'nu_max_convidados': _vagasController.text,
      'nu_cep': _cepController.text,
      'nu_casa': _numeroController.text,
      'hr_encontro': dataHora.toIso8601String(),
      'vl_foto': urlFoto,
    };

    try {
      final res = await CardapioService.createJantar(dados);
      
      bool sucesso = false;
      if (res != null) {
        if (res['registros'] == 1) {
           sucesso = true;
        } else if (res['dados'] != null && res['dados'] is Map && res['dados']['Mensagem'] == 'Jantar criado com sucesso!') {
           sucesso = true;
        }
      }

      if (sucesso) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jantar publicado!"), backgroundColor: Colors.green));
          Navigator.pop(context, true); 
        }
      } else {
        _mostrarErro("Erro: ${res?['Mensagem']}");
      }
    } catch (e) {
      _mostrarErro("Erro: $e");
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarErro(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Novo Jantar", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _escolherImagem,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  image: _imagemSelecionada != null ? DecorationImage(image: FileImage(_imagemSelecionada!), fit: BoxFit.cover) : null,
                ),
                child: _imagemSelecionada == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.camera_alt, size: 50, color: Colors.grey), SizedBox(height: 8), Text("Toque para adicionar foto", style: TextStyle(color: Colors.grey))]) : null,
              ),
            ),
            const SizedBox(height: 24),
            CampoDeTextoCustomizado(controller: _tituloController, dica: "Nome do Prato"),
            const SizedBox(height: 12),
            CampoDeTextoCustomizado(controller: _descricaoController, dica: "Descrição"),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: CampoDeTextoCustomizado(controller: _precoController, dica: "Preço")), const SizedBox(width: 12), Expanded(child: CampoDeTextoCustomizado(controller: _vagasController, dica: "Vagas"))]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _selecionarData, icon: const Icon(Icons.calendar_today), label: Text(_dataSelecionada == null ? "Data" : DateFormat('dd/MM').format(_dataSelecionada!)))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: _selecionarHora, icon: const Icon(Icons.access_time), label: Text(_horaSelecionada == null ? "Hora" : _horaSelecionada!.format(context)))),
            ]),
            const SizedBox(height: 12),
            Row(children: [Expanded(flex: 2, child: CampoDeTextoCustomizado(controller: _cepController, dica: "CEP")), const SizedBox(width: 12), Expanded(flex: 1, child: CampoDeTextoCustomizado(controller: _numeroController, dica: "Nº"))]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _estaCarregando ? null : _criarJantar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _estaCarregando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("PUBLICAR JANTAR", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}