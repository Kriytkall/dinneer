import 'package:flutter/material.dart';
import '../service/refeicao/Refeicao.dart'; // Importa o modelo
import '../service/refeicao/RefeicaoService.dart';
import '../widgets/card_refeicao.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  late Future<List<Refeicao>> _refeicoesFuture;

  @override
  void initState() {
    super.initState();
    _refeicoesFuture = _carregarRefeicoes();
  }
  Future<List<Refeicao>> _carregarRefeicoes() async {
    try {
      final resposta = await RefeicaoService.getRefeicoes();
      if (resposta['dados'] != null) {
        // Converte cada item do JSON para um objeto Refeicao
        final dados = List<dynamic>.from(resposta['dados']);
        return dados.map((item) => Refeicao.fromMap(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Erro ao carregar refeições: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar jantares."), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterButtons(),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            // O FutureBuilder agora trabalha com a nossa classe Refeicao
            child: FutureBuilder<List<Refeicao>>(
              future: _refeicoesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                } 
                else if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                } 
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum jantar disponível no momento."));
                } 
                else {
                  final refeicoes = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: refeicoes.length,
                    itemBuilder: (context, index) {
                      final refeicao = refeicoes[index];
                      // CORREÇÃO: Passamos o objeto refeicao para o card!
                      return CardRefeicao(refeicao: refeicao); 
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar por prato, cidade...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        _buildFilterChip('Data'),
        const SizedBox(width: 8),
        _buildFilterChip('Preço'),
        const SizedBox(width: 8),
        _buildFilterChip('Tipo'),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.black54)),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

