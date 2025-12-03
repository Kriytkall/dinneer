import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import '../widgets/card_refeicao.dart';

class TelaReservas extends StatefulWidget {
  const TelaReservas({super.key});

  @override
  State<TelaReservas> createState() => _TelaReservasState();
}

class _TelaReservasState extends State<TelaReservas> {
  int _filtroSelecionado = 1; 
  late Future<List<Cardapio>> _minhasReservasFuture;
  late Future<List<Cardapio>> _meusJantaresCriadosFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // Transforma em Future<void> para poder usar no onRecarregar
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
      
      final resposta = await EncontroService.getMinhasReservas(int.parse(idStr));
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Cardapio.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Erro reservas: $e");
      return [];
    }
  }

  Future<List<Cardapio>> _buscarJantaresCriados() async {
    try {
      final idStr = await SessionService.pegarUsuarioId();
      if (idStr == null) return [];

      final resposta = await EncontroService.getMeusJantaresCriados(int.parse(idStr));
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Cardapio.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Erro jantares criados: $e");
      return [];
    }
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
          title: const Text('Minhas Reservas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
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
            _buildListaComFiltro(_minhasReservasFuture, ehReserva: true),
            _buildListaComFiltro(_meusJantaresCriadosFuture, ehReserva: false),
          ],
        ),
      ),
    );
  }

  Widget _buildListaComFiltro(Future<List<Cardapio>> future, {required bool ehReserva}) {
    return Column(
      children: [
        if (ehReserva) 
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip('Pendentes', 0),
                const SizedBox(width: 10),
                _buildFilterChip('Confirmados', 1),
                const SizedBox(width: 10),
                _buildFilterChip('Histórico', 2),
              ],
            ),
          ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhum item encontrado.'));
              }

              final todos = snapshot.data!;
              final filtrados = todos.where((jantar) {
                if (!ehReserva) return true;
                final agora = DateTime.now();
                if (_filtroSelecionado == 2) { 
                   return jantar.hrEncontro.isBefore(agora);
                } else { 
                   return jantar.hrEncontro.isAfter(agora);
                }
              }).toList();

              if (filtrados.isEmpty) return const Center(child: Text("Nenhum item nesta categoria."));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final reserva = filtrados[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Column(
                      children: [
                        CardRefeicao(
                          refeicao: reserva,
                          onRecarregar: _carregarDados, // <--- A MÁGICA AQUI
                        ),
                        if (ehReserva && _filtroSelecionado == 1)
                          Transform.translate(
                            offset: const Offset(0, -10),
                            child: _buildStatusConfirmadoBar(),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ... (Widgets _buildStatusConfirmadoBar e _buildFilterChip mantidos iguais) ...
  Widget _buildStatusConfirmadoBar() {
    return Container(padding: const EdgeInsets.fromLTRB(20, 22, 20, 12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('CONFIRMADO', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1)), const Icon(Icons.check_circle, color: Colors.green, size: 20)]));
  }
  Widget _buildFilterChip(String label, int index) {
    final bool isSelected = _filtroSelecionado == index;
    return GestureDetector(onTap: () => setState(() => _filtroSelecionado = index), child: Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), decoration: BoxDecoration(color: isSelected ? Colors.grey[300] : Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold))));
  }
}