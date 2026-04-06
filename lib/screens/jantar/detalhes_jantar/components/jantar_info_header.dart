import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';

class JantarInfoHeader extends StatelessWidget {
  final Cardapio refeicao;

  const JantarInfoHeader({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          refeicao.nmCardapio, 
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 8),
        Text(
          refeicao.precoFormatado, 
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)
        ),
      ],
    );
  }
}
