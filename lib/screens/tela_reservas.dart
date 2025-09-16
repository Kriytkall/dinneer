import 'package:flutter/material.dart';
import '../service/refeicao/Refeicao.dart';
import '../service/refeicao/RefeicaoService.dart';
import '../widgets/card_refeicao.dart';

class TelaReservas extends StatefulWidget {
  const TelaReservas({super.key});

  @override
  State<TelaReservas> createState() => _TelaReservasState();
}

class _TelaReservasState extends State<TelaReservas> {
  int _filtroSelecionado = 1;
  late Future<List<Refeicao>> _reservasFuture;

  @override
  void initState() {
    super.initState();
    _reservasFuture = _carregarReservas();
  }

  Future<List<Refeicao>> _carregarReservas() async {
    try {
      final resposta = await RefeicaoService.getRefeicoes();
      if (resposta['dados'] != null) {
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Refeicao.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Erro ao carregar reservas: $e");
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
          title: const Text(
            'Minhas Reservas',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black54),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Minhas Reservas'),
              Tab(text: 'Meus Jantares Criados'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMinhasReservasTab(),
            const Center(child: Text('Conteúdo de Meus Jantares Criados')),
          ],
        ),
      ),
    );
  }

  Widget _buildMinhasReservasTab() {
    return Column(
      children: [
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
          // Usamos o FutureBuilder para carregar a lista dinamicamente
          child: FutureBuilder<List<Refeicao>>(
            future: _reservasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma reserva encontrada.'));
              }

              final reservas = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: reservas.length,
                itemBuilder: (context, index) {
                  final reserva = reservas[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Column(
                      children: [
                        CardRefeicao(refeicao: reserva),
                        if (_filtroSelecionado == 1)
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

  Widget _buildStatusConfirmadoBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CONFIRMADO',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Ver Chat do Grupo'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final bool isSelected = _filtroSelecionado == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSelecionado = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

