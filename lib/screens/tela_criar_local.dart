import 'package:flutter/material.dart';
import 'package:dinneer/service/local/LocalService.dart';

class TelaCriarLocal extends StatefulWidget {
  final int idUsuario;

  const TelaCriarLocal({super.key, required this.idUsuario});

  @override
  State<TelaCriarLocal> createState() => _TelaCriarLocalState();
}

class _TelaCriarLocalState extends State<TelaCriarLocal> {
  final _cepController = TextEditingController();
  final _casaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _complementoController = TextEditingController();

  bool enviando = false;

  Future<void> _enviarFormulario() async {
    if (enviando) return;

    final cep = _cepController.text.trim();
    final casa = _casaController.text.trim();
    final cnpj = _cnpjController.text.trim();
    final complemento = _complementoController.text.trim();

    if (cep.isEmpty || casa.isEmpty || cnpj.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos obrigatórios!")),
      );
      return;
    }

    setState(() => enviando = true);

    final dados = {
      "nu_cep": cep,
      "nu_casa": casa,
      "id_usuario": widget.idUsuario.toString(),
      "nu_cnpj": cnpj,
      "dc_complemento": complemento,
    };

    try {
      final resposta = await LocalService.createLocal(dados);

      print("RESPOSTA BACKEND: $resposta");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Local criado com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("ERRO AO ENVIAR LOCAL: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao enviar dados.")),
      );
    } finally {
      setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Local"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              decoration: const InputDecoration(
                labelText: "CEP",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _casaController,
              decoration: const InputDecoration(
                labelText: "Número da Casa",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cnpjController,
              decoration: const InputDecoration(
                labelText: "CNPJ",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _complementoController,
              decoration: const InputDecoration(
                labelText: "Complemento (opcional)",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: enviando ? null : _enviarFormulario,
              child: enviando
                  ? const CircularProgressIndicator()
                  : const Text("Enviar"),
            ),
          ],
        ),
      ),
    );
  }
}
