import 'package:flutter/material.dart';
import '../widgets/barra_de_navegacao.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _paginaAtual = 0;

  final List<Widget> _paginas = [
    // Páginas de exemplo para cada item da navegação
    const Center(child: Text('Página Home', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Página Chat', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Página Adicionar', style: TextStyle(fontSize: 24))),
    const Center(
        child: Text('Página Restaurantes', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Página Perfil', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permite que o body fique atrás da barra de navegação
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dinneer'),
        automaticallyImplyLeading: false, // Remove o botão de voltar
      ),
      body: _paginas[_paginaAtual],
      bottomNavigationBar: BarraNavegacaoCustomizada(
        index: _paginaAtual,
        onTap: (index) => setState(() => _paginaAtual = index),
      ),
    );
  }
}

