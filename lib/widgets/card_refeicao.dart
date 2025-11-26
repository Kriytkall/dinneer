import 'package:dinneer/service/refeicao/Refeicao.dart';
import 'package:flutter/material.dart';
import '../screens/tela_detalhes_jantar.dart';

class CardRefeicao extends StatelessWidget {
  final Refeicao refeicao;

  const CardRefeicao({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // AGORA SIM: Passamos o objeto 'refeicao' para a próxima tela
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TelaDetalhesJantar(refeicao: refeicao)),
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
              Container(
                width: 110,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: const Icon(Icons.dinner_dining_outlined,
                    color: Colors.white, size: 50),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        refeicao.nmCardapio,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      _buildInfoRow(
                          Icons.calendar_today_rounded, refeicao.dataFormatada),

                      Text(
                        '${refeicao.precoFormatado} por pessoa',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildUserInfo(refeicao.nmUsuarioAnfitriao),

                      _buildInfoRow(Icons.people_alt_rounded,
                          '?/${refeicao.nuMaxConvidados} vagas'),
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

  Widget _buildUserInfo(String nomeAnfitriao) {
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
              'Por $nomeAnfitriao',
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