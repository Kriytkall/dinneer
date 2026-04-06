import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/widgets/card_refeicao.dart';
import 'filtro_chips.dart';

class ListaParticipacao extends StatelessWidget {
  final Future<List<Cardapio>> minhasReservasFuture;
  final int filtroParticipacao;
  final Function(int) onFiltroChanged;
  final VoidCallback onRecarregar;

  const ListaParticipacao({
    super.key,
    required this.minhasReservasFuture,
    required this.filtroParticipacao,
    required this.onFiltroChanged,
    required this.onRecarregar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FiltroChips(
                  label: 'Pendentes',
                  value: 0,
                  groupValue: filtroParticipacao,
                  onTap: onFiltroChanged,
                ),
                const SizedBox(width: 10),
                FiltroChips(
                  label: 'Confirmados',
                  value: 1,
                  groupValue: filtroParticipacao,
                  onTap: onFiltroChanged,
                ),
                const SizedBox(width: 10),
                FiltroChips(
                  label: 'Histórico',
                  value: 2,
                  groupValue: filtroParticipacao,
                  onTap: onFiltroChanged,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: minhasReservasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma reserva encontrada.'));
              }

              final todos = snapshot.data!;
              final filtrados = todos.where((jantar) {
                final agora = DateTime.now();
                final bool ehPassado = jantar.hrEncontro.isBefore(agora);
                final bool ehFuturo = !ehPassado;
                final String status = jantar.statusReserva ?? 'P';

                if (filtroParticipacao == 2) {
                  return ehPassado;
                } else if (filtroParticipacao == 0) {
                  return ehFuturo && status == 'P';
                } else if (filtroParticipacao == 1) {
                  return ehFuturo && status == 'C';
                }

                return false;
              }).toList();

              if (filtrados.isEmpty) {
                return const Center(
                  child: Text("Nenhum item nesta categoria."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  return CardRefeicao(
                    refeicao: filtrados[index],
                    onRecarregar: onRecarregar,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
