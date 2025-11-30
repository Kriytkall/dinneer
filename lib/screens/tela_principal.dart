import 'package:flutter/material.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import '../widgets/barra_de_navegacao.dart';
import 'tela_home.dart';
import 'tela_perfil.dart';
import 'tela_reservas.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _paginaAtual = 0;
  List<Widget> _paginas = [];
  int idUsuario = -1;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    String? idUsuarioStr = await SessionService.pegarUsuarioId();

    idUsuario = int.tryParse(idUsuarioStr ?? "-1") ?? -1;

    print("ID DO USUÁRIO CARREGADO: $idUsuario");

    _paginas = [
      TelaHome(idUsuarioLogado: idUsuario),
      const Center(
          child: Text('Página Chat', style: TextStyle(fontSize: 24))),
      const TelaReservas(),
      TelaPerfil(dadosUsuario: {"id_usuario": idUsuario}),
    ];

    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _paginaAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_paginas.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _paginas[_paginaAtual],
      bottomNavigationBar: BarraNavegacaoCustomizada(
        index: _paginaAtual,
        onTap: _onItemTapped,
      ),
    );
  }
}
