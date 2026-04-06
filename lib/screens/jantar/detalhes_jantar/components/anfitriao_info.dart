import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';

class AnfitriaoInfo extends StatelessWidget {
  final Cardapio refeicao;

  const AnfitriaoInfo({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              (refeicao.urlFotoAnfitriao != null &&
                  refeicao.urlFotoAnfitriao!.isNotEmpty)
              ? NetworkImage(refeicao.urlFotoAnfitriao!)
              : null,
          child:
              (refeicao.urlFotoAnfitriao == null ||
                  refeicao.urlFotoAnfitriao!.isEmpty)
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Anfitrião",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              refeicao.nmUsuarioAnfitriao,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
