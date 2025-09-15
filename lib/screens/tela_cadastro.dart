// lib/screens/tela_cadastro.dart

import 'package:flutter/material.dart';
import '../widgets/campo_de_texto.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  int _etapaAtual = 1;

  // 1. Criamos um controlador para cada campo de texto.
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController(); // Novo
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _telefoneController = TextEditingController(); // Novo

  // Função para avançar para a próxima etapa, com validação de senha.
  void _proximaEtapa() {
    if (_senhaController.text == _confirmarSenhaController.text) {
      // Se as senhas forem iguais, avança.
      setState(() {
        _etapaAtual = 2;
      });
    } else {
      // Se forem diferentes, exibe uma mensagem de erro (um Snackbar).
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem. Tente novamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Função para voltar para a etapa anterior.
  void _etapaAnterior() {
    setState(() {
      _etapaAtual = 1;
    });
  }

  // 2. Função final para realizar o cadastro.
  void _fazerCadastro() {
    // Aqui pegamos os valores de TODOS os controladores.
    final email = _emailController.text;
    final senha = _senhaController.text;
    final nome = _nomeController.text;
    final sobrenome = _sobrenomeController.text;
    final telefone = _telefoneController.text;

    // Imprimindo no console para confirmar que todos os dados foram capturados.
    print('--- DADOS DO CADASTRO ---');
    print('Email: $email');
    print('Senha: $senha');
    print('Nome: $nome');
    print('Sobrenome: $sobrenome');
    print('Telefone: $telefone');
    print('-------------------------');

    // Futuramente, aqui você chamará o serviço para criar o usuário.
  }

  // 3. Adicionamos o método dispose para limpar todos os controladores.
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            if (_etapaAtual == 2) {
              _etapaAnterior();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Cadastro $_etapaAtual/2',
          style: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: _etapaAtual == 1 ? _buildEtapa1() : _buildEtapa2(),
          ),
        ),
      ),
    );
  }

  Widget _buildEtapa1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.restaurant_menu, size: 80, color: Colors.black54),
        const SizedBox(height: 20),
        const Text('DINNEER',
            style: TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('A MELHOR REFEIÇÃO DE SUA VIDA',
            style: TextStyle(
                fontSize: 12, color: Colors.black54, letterSpacing: 1)),
        const SizedBox(height: 40),
        // 4. Passamos os controladores para cada campo de texto.
        CampoDeTextoCustomizado(
          controller: _emailController,
          dica: 'Email',
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _senhaController,
          dica: 'Senha',
          textoObscuro: true,
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _confirmarSenhaController,
          dica: 'Confirmar Senha',
          textoObscuro: true,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proximaEtapa,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0),
            child: const Text('CONTINUAR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        _buildLinkLogin(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEtapa2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: () {
                  print('Adicionar imagem');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // 4. Continuamos passando os controladores.
        CampoDeTextoCustomizado(
          controller: _nomeController,
          dica: 'Nome',
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _sobrenomeController,
          dica: 'Sobrenome',
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: _telefoneController,
          dica: 'Telefone',
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // 5. O botão final agora chama a função de cadastro.
            onPressed: _fazerCadastro,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0),
            child: const Text('CADASTRAR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        _buildLinkLogin(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLinkLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Já tem login? ', style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Entre',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }
}