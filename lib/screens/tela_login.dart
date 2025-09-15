// lib/screens/tela_login.dart

import 'package:dinneer/service/usuario/UsuarioService.dart';
import 'package:flutter/material.dart';
import '../widgets/campo_de_texto.dart';
import 'tela_cadastro.dart';
import '../screens/tela_principal.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Variável para controlar o estado de carregamento do botão
  bool _estaCarregando = false;

  void _fazerLogin() async {
    // Evita que o utilizador clique várias vezes no botão
    if (_estaCarregando) return;

    final email = _emailController.text;
    final senha = _senhaController.text;

    // Ativa o indicador de carregamento
    setState(() {
      _estaCarregando = true;
    });

    try {
      var resposta = await UsuarioService.login(email, senha);
      
      // Verificamos se a resposta contém os dados do utilizador, indicando sucesso.
      if (resposta['dados'] != null) {
        
        debugPrint('Login bem-sucedido! Bem-vindo, ${resposta['dados']['nome']}');

        // Navega para o ecrã principal e remove o ecrã de login do histórico
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaPrincipal()),
        );

      } else {
        // Se não houver dados, o login falhou (ex: senha errada)
        // Mostramos a mensagem de erro que veio do servidor PHP
        _mostrarMensagemErro(resposta['Mensagem'] ?? 'Email ou senha inválidos.');
      }

    } catch (e) {
      debugPrint('Ocorreu um erro ao tentar fazer login: $e');
      _mostrarMensagemErro('Não foi possível ligar ao servidor. Tente novamente.');
    } finally {
      // Desativa o indicador de carregamento, mesmo que ocorra um erro
      if (mounted) {
        setState(() {
          _estaCarregando = false;
        });
      }
    }
  }

  // Função auxiliar para mostrar uma notificação de erro
  void _mostrarMensagemErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.black54,
                ),
                const SizedBox(height: 20),
                const Text(
                  'DINNEER',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A MELHOR REFEIÇÃO DE SUA VIDA',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 40),
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TelaCadastro()),
                        );
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Desativa o botão durante o carregamento
                    onPressed: _estaCarregando ? null : _fazerLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    // Mostra um indicador de progresso ou o texto do botão
                    child: _estaCarregando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TelaPrincipal()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Entrar desenvolvimento',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

