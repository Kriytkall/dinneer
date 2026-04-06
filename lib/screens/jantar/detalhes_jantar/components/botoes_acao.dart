import 'package:flutter/material.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/screens/jantar/tela_editar_jantar.dart';
import 'package:dinneer/widgets/modal_avaliacao.dart';

class BotoesAcao extends StatelessWidget {
  final bool souOAnfitriao;
  final bool estaLotado;
  final bool jaReservei;
  final String? statusReserva;
  final Cardapio refeicao;
  final int? idUsuarioLogado;
  final VoidCallback onConfirmarExclusao;
  final VoidCallback onConfirmarCancelamentoReserva;
  final Function(BuildContext) onMostrarModalAgendamento;

  const BotoesAcao({
    super.key,
    required this.souOAnfitriao,
    required this.estaLotado,
    required this.jaReservei,
    required this.statusReserva,
    required this.refeicao,
    required this.idUsuarioLogado,
    required this.onConfirmarExclusao,
    required this.onConfirmarCancelamentoReserva,
    required this.onMostrarModalAgendamento,
  });

  @override
  Widget build(BuildContext context) {
    if (souOAnfitriao) {
      return _buildBotoesAnfitriao(context);
    }
    return _buildBotaoConvidado(context);
  }

  Widget _buildBotoesAnfitriao(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final atualizou = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaEditarJantar(jantar: refeicao),
                ),
              );
              if (atualizou == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.black),
            ),
            child: const Text(
              "EDITAR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirmarExclusao,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "CANCELAR",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoConvidado(BuildContext context) {
    final bool jantarJaPassou = refeicao.hrEncontro.isBefore(DateTime.now());

    if (jaReservei) {
      if (jantarJaPassou) {
        return ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => ModalAvaliacao(
                idUsuario: idUsuarioLogado!,
                idEncontro: refeicao.idEncontro,
                onAvaliacaoConcluida: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Obrigado pela avaliação!")),
                  );
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "AVALIAR EXPERIÊNCIA",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      }

      if (statusReserva == 'P') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(Icons.access_time, color: Colors.orange, size: 30),
              SizedBox(height: 8),
              Text(
                "Solicitação Pendente",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                "Aguarde o anfitrião aceitar.",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }

      return ElevatedButton(
        onPressed: onConfirmarCancelamentoReserva,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.red),
          ),
          elevation: 0,
        ),
        child: const Text(
          "CANCELAR RESERVA",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    if (jantarJaPassou) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "JANTAR ENCERRADO",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    return ElevatedButton(
      onPressed: estaLotado ? null : () => onMostrarModalAgendamento(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: estaLotado ? Colors.grey : Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        estaLotado ? 'JANTAR LOTADO' : 'SOLICITAR RESERVA',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
