import 'package:flutter/material.dart';
import '../widgets/barra_de_navegacao.dart';
import 'tela_home.dart';
import 'tela_perfil.dart';
import 'tela_reservas.dart'; // Importando a nova tela

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
    const TelaReservas(), // Tela de Reservas adicionada aqui
    const TelaPerfil(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _paginaAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_paginaAtual],
      bottomNavigationBar: BarraNavegacaoCustomizada(
        index: _paginaAtual,
        onTap: _onItemTapped,
      ),
    );
  }
}

