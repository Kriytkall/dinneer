import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'components/lista_participacao.dart';
import 'components/lista_organizacao.dart';
import 'components/modal_gerenciar_participantes.dart';

class TelaReservas extends StatefulWidget {
  const TelaReservas({super.key});

  @override
  State<TelaReservas> createState() => _TelaReservasState();
}

class _TelaReservasState extends State<TelaReservas> {
  int _filtroParticipacao = 0;
  int _filtroOrganizacao = 0;

  late Future<List<Cardapio>> _minhasReservasFuture;
  late Future<List<Cardapio>> _meusJantaresCriadosFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _minhasReservasFuture = _buscarReservas();
      _meusJantaresCriadosFuture = _buscarJantaresCriados();
    });
  }

  Future<List<Cardapio>> _buscarReservas() async {
    try {
      final idStr = await SessionService.pegarUsuarioId();
      if (idStr == null) return [];

      final resposta = await EncontroService.getMinhasReservas(
        int.parse(idStr),
      );
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Cardapio.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Cardapio>> _buscarJantaresCriados() async {
    try {
      final idStr = await SessionService.pegarUsuarioId();
      if (idStr == null) return [];

      final resposta = await EncontroService.getMeusJantaresCriados(
        int.parse(idStr),
      );
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Cardapio.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void _abrirGerenciamento(BuildContext context, Cardapio jantar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalGerenciarParticipantes(
        jantar: jantar,
        onAtualizar: _carregarDados,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Minhas Reservas',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Participei'),
              Tab(text: 'Organizei'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListaParticipacao(
              minhasReservasFuture: _minhasReservasFuture,
              filtroParticipacao: _filtroParticipacao,
              onFiltroChanged: (v) => setState(() => _filtroParticipacao = v),
              onRecarregar: _carregarDados,
            ),
            ListaOrganizacao(
              meusJantaresCriadosFuture: _meusJantaresCriadosFuture,
              filtroOrganizacao: _filtroOrganizacao,
              onFiltroChanged: (v) => setState(() => _filtroOrganizacao = v),
              onRecarregar: _carregarDados,
              onAbrirGerenciamento: _abrirGerenciamento,
            ),
          ],
        ),
      ),
    );
  }
}
