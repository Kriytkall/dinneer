import 'package:flutter/material.dart';
import '../widgets/barra_de_navegacao.dart';
import 'tela_home.dart';
import 'tela_perfil.dart';
import 'tela_reservas.dart';

class TelaPrincipal extends StatefulWidget {
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
    // Obtendo o ID de forma segura (garantindo que seja int)
    int idUsuario = int.tryParse(widget.dadosUsuario['id_usuario'].toString()) ?? 0;

    _paginas = [
      // Passamos o ID para a Home
      TelaHome(idUsuarioLogado: idUsuario),
      const Center(child: Text('Página Chat', style: TextStyle(fontSize: 24))),
      const TelaReservas(),
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