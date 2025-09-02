import 'package:flutter/material.dart';
import '../widgets/barra_de_navegacao.dart';
import 'tela_home.dart';
import 'tela_perfil.dart'; // Importa a nova tela de perfil

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _paginaAtual = 0;

  final List<Widget> _paginas = [
    const TelaHome(),
    const Center(child: Text('Página Chat', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Página Pedidos', style: TextStyle(fontSize: 24))),
    const TelaPerfil(), // Adiciona a TelaPerfil à lista de páginas
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_paginaAtual],
      bottomNavigationBar: BarraNavegacaoCustomizada(
        index: _paginaAtual,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
          });
        },
      ),
    );
  }
}

