import 'package:flutter/material.dart';
import '../widgets/barra_de_navegacao.dart';
import 'tela_home.dart';
import 'tela_perfil.dart';
import 'tela_reservas.dart';

class TelaPrincipal extends StatefulWidget {
  // Recebe os dados do usuário logado
  final Map<String, dynamic> dadosUsuario;

  const TelaPrincipal({super.key, required this.dadosUsuario});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _paginaAtual = 0;
  late List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
    // Inicializa as páginas passando os dados para onde for necessário
    _paginas = [
      const TelaHome(),
      const Center(child: Text('Página Chat', style: TextStyle(fontSize: 24))),
      const TelaReservas(),
      // Passamos os dados para a TelaPerfil
      TelaPerfil(dadosUsuario: widget.dadosUsuario),
    ];
  }

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