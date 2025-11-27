import 'package:flutter/material.dart';
import '../widgets/campo_de_texto.dart';
import '../service/usuario/UsuarioService.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  int _etapaAtual = 1;
  bool _estaCarregando = false;

  // Controladores
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _cpfController = TextEditingController(); // NOVO: Banco exige CPF

  void _proximaEtapa() {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha email e senha.')));
       return;
    }
    if (_senhaController.text == _confirmarSenhaController.text) {
      setState(() {
        _etapaAtual = 2;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _etapaAnterior() {
    setState(() {
      _etapaAtual = 1;
    });
  }

  void _fazerCadastro() async {
    if (_nomeController.text.isEmpty || _cpfController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e CPF são obrigatórios.')),
      );
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    // Mapeando EXATAMENTE como o UsuarioController.php espera
    final dadosUsuario = {
      'nm_usuario': _nomeController.text,
      'nm_sobrenome': _sobrenomeController.text,
      'vl_email': _emailController.text,
      'vl_senha': _senhaController.text,
      'nu_cpf': _cpfController.text, // Obrigatório no PHP
    };

    try {
      final resposta = await UsuarioService.createUsuario(dadosUsuario);

      // Verificação flexível de sucesso
      if (resposta != null && (resposta['dados'] != null || resposta['Mensagem'] == 'Sucesso')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado! Faça login.'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(); // Volta para o login
        }
      } else {
        _mostrarErro(resposta['Mensagem'] ?? 'Erro ao cadastrar.');
      }
    } catch (e) {
      _mostrarErro('Erro de conexão: $e');
    } finally {
      if (mounted) {
        setState(() {
          _estaCarregando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _cpfController.dispose();
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
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
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
        const Text('DINNEER', style: TextStyle(fontFamily: 'serif', fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 40),
        CampoDeTextoCustomizado(controller: _emailController, dica: 'Email'),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(controller: _senhaController, dica: 'Senha', textoObscuro: true),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(controller: _confirmarSenhaController, dica: 'Confirmar Senha', textoObscuro: true),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proximaEtapa,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('CONTINUAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        _buildLinkLogin(),
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
            CircleAvatar(radius: 60, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 60, color: Colors.grey[400])),
            CircleAvatar(radius: 20, backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20), onPressed: () {})),
          ],
        ),
        const SizedBox(height: 40),
        CampoDeTextoCustomizado(controller: _nomeController, dica: 'Nome'),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(controller: _sobrenomeController, dica: 'Sobrenome'),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(controller: _cpfController, dica: 'CPF (apenas números)'), 
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _estaCarregando ? null : _fazerCadastro,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: _estaCarregando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text('CADASTRAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
        _buildLinkLogin(),
      ],
    );
  }

  Widget _buildLinkLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Já tem login? ', style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () { Navigator.of(context).pop(); },
          child: const Text('Entre', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ],
    );
  }
}