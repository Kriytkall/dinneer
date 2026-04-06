import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';

class JantarDetalhesCard extends StatelessWidget {
  final Cardapio refeicao;

  const JantarDetalhesCard({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoRow(Icons.calendar_today, refeicao.dataFormatada),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          _buildInfoRow(
            Icons.people_alt_outlined,
            '${refeicao.nuConvidadosConfirmados}/${refeicao.nuMaxConvidados} vagas'
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)
        ),
      ],
    );
  }
}
