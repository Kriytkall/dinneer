import 'package:flutter/material.dart';

class JantarDescricao extends StatelessWidget {
  final String descricao;

  const JantarDescricao({super.key, required this.descricao});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sobre o Jantar",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          descricao.isNotEmpty ? descricao : "Sem descrição.",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
