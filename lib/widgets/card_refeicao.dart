import 'package:flutter/material.dart';
import '../screens/tela_detalhes_jantar.dart';

class CardRefeicao extends StatelessWidget {
  const CardRefeicao({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TelaDetalhesJantar()),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder da Imagem
              Container(
                width: 110,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              const SizedBox(width: 16),
              // Coluna de Detalhes
              Expanded(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Jantar Italiano Gourmet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildInfoRow(
                          Icons.calendar_today_rounded, '12/09 às 19h'),
                      const Text(
                        'R\$ 50,00 por pessoa',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildUserInfo(),
                      _buildInfoRow(Icons.people_alt_rounded, '0/4 vagas'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oferecido',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              'Por Nome de usuário',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    );
  }
}

