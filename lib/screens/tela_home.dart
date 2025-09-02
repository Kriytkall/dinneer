import 'package:flutter/material.dart';
import '../widgets/card_refeicao.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Este widget retorna apenas o conteúdo do corpo da tela (o corpo do Scaffold)
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilterButtons(),
          const SizedBox(height: 24),
          // Para dados dinâmicos, o ideal seria usar um ListView.builder
          const CardRefeicao(),
          const CardRefeicao(),
          const CardRefeicao(),
          const CardRefeicao(),
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
