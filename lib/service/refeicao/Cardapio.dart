import 'package:intl/intl.dart';

class Cardapio {
  final int idUsuario;
  final String nmUsuarioAnfitriao;
  final String nmCardapio;
  final int idRefeicao;
  final DateTime hrEncontro;
  final int nuMaxConvidados;
  final double precoRefeicao;
  final int idLocal;
  final String nuCep;
  final String nuCasa;

  Cardapio({
    required this.idUsuario,
    required this.nmUsuarioAnfitriao,
    required this.nmCardapio,
    required this.idRefeicao,
    required this.hrEncontro,
    required this.nuMaxConvidados,
    required this.precoRefeicao,
    required this.idLocal,
    required this.nuCep,
    required this.nuCasa,
  });

  factory Cardapio.fromMap(Map<String, dynamic> map) {
    int _toInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    double _toDouble(dynamic value) {
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Cardapio(
      idUsuario: _toInt(map['id_usuario']),
      nmUsuarioAnfitriao: map['nm_usuario_anfitriao'].toString(),
      nmCardapio: map['nm_cardapio'].toString(),
      // CORREÇÃO AQUI: O PHP retorna 'id_cardapio', não 'id_refeicao'
      idRefeicao: _toInt(map['id_cardapio']), 
      hrEncontro: DateTime.tryParse(map['hr_encontro'].toString()) ?? DateTime.now(),
      nuMaxConvidados: _toInt(map['nu_max_convidados']),
      precoRefeicao: _toDouble(map['preco_refeicao']),
      idLocal: _toInt(map['id_local']),
      nuCep: map['nu_cep'].toString(),
      nuCasa: map['nu_casa'].toString(),
    );
  }

  String get dataFormatada {
    try {
      final DateFormat formatador = DateFormat("dd 'de' MMMM 'às' HH:mm'h'", 'pt_BR');
      return formatador.format(hrEncontro);
    } catch (e) {
      return "Data a definir";
    }
  }

  String get precoFormatado {
    try {
      final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      return formatador.format(precoRefeicao);
    } catch (e) {
      return "R\$ 0,00";
    }
  }
}