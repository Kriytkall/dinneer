import 'package:flutter/material.dart';
import '../widgets/barra_de_navegacao.dart';
import 'tela_home.dart';
import 'tela_perfil.dart';
import 'tela_reservas.dart';

class TelaPrincipal extends StatefulWidget {
  // Dados recebidos do Login
  final Map<String, dynamic> dadosUsuario;

  const TelaPrincipal({super.key, required this.dadosUsuario});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _paginaAtual = 0;
  // Não inicializamos a lista aqui para poder acessar 'widget.dadosUsuario'
  late List<Widget> _paginas; 

  @override
  void initState() {
    super.initState();
    
    // DEBUG: Verificando se os dados chegaram na Principal
    debugPrint("TELA PRINCIPAL RECEBEU: ${widget.dadosUsuario}");

    // Extrai o ID com segurança
    int idUsuario = 0;
    if (widget.dadosUsuario['id_usuario'] != null) {
      idUsuario = int.tryParse(widget.dadosUsuario['id_usuario'].toString()) ?? 0;
    }

    // AQUI É O SEGREDO: Criamos a lista dentro do initState
    _paginas = [
      TelaHome(idUsuarioLogado: idUsuario),
      const Center(child: Text('Página Chat', style: TextStyle(fontSize: 24))),
      const TelaReservas(),
      // Passamos os dados CORRETOS para o Perfil
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