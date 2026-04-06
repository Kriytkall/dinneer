import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/widgets/card_refeicao.dart';
import 'filtro_chips.dart';

class ListaOrganizacao extends StatelessWidget {
  final Future<List<Cardapio>> meusJantaresCriadosFuture;
  final int filtroOrganizacao;
  final Function(int) onFiltroChanged;
  final VoidCallback onRecarregar;
  final Function(BuildContext, Cardapio) onAbrirGerenciamento;

  const ListaOrganizacao({
    super.key,
    required this.meusJantaresCriadosFuture,
    required this.filtroOrganizacao,
    required this.onFiltroChanged,
    required this.onRecarregar,
    required this.onAbrirGerenciamento,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FiltroChips(
                label: 'Próximos',
                value: 0,
                groupValue: filtroOrganizacao,
                onTap: onFiltroChanged,
              ),
              const SizedBox(width: 10),
              FiltroChips(
                label: 'Histórico',
                value: 2,
                groupValue: filtroOrganizacao,
                onTap: onFiltroChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Cardapio>>(
            future: meusJantaresCriadosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Você ainda não organizou jantares.'),
                );
              }

              final todos = snapshot.data!;
              final filtrados = todos.where((jantar) {
                final agora = DateTime.now();
                if (filtroOrganizacao == 2) {
                  return jantar.hrEncontro.isBefore(agora);
                } else {
                  return jantar.hrEncontro.isAfter(agora);
                }
              }).toList();

              if (filtrados.isEmpty) {
                return const Center(child: Text("Nenhum jantar encontrado."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final jantar = filtrados[index];
                  final bool temPendencias = jantar.nuSolicitacoesPendentes > 0;

                  return Column(
                    children: [
                      CardRefeicao(
                        refeicao: jantar,
                        onRecarregar: onRecarregar,
                      ),
                      if (filtroOrganizacao == 0)
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextButton.icon(
                              onPressed: () =>
                                  onAbrirGerenciamento(context, jantar),
                              icon: Icon(
                                Icons.people,
                                color: temPendencias
                                    ? Colors.red
                                    : Colors.black87,
                              ),
                              label: Text(
                                temPendencias
                                    ? "GERENCIAR (${jantar.nuSolicitacoesPendentes} NOVOS PEDIDOS)"
                                    : "VER LISTA DE CONVIDADOS",
                                style: TextStyle(
                                  color: temPendencias
                                      ? Colors.red
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
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
