import 'package:flutter/material.dart';

class PerfilPublicoHeader extends StatelessWidget {
  final String nomeCompleto;
  final String? fotoUrl;
  final double media;
  final int totalAvaliacoes;

  const PerfilPublicoHeader({
    super.key,
    required this.nomeCompleto,
    required this.fotoUrl,
    required this.media,
    required this.totalAvaliacoes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                (fotoUrl != null && fotoUrl!.isNotEmpty && fotoUrl != 'null')
                ? NetworkImage(fotoUrl!)
                : null,
            child: (fotoUrl == null || fotoUrl!.isEmpty || fotoUrl == 'null')
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            nomeCompleto,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 4),
              Text(
                media.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " ($totalAvaliacoes avaliações)",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
