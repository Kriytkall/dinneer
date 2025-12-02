import 'package:intl/intl.dart';

class Cardapio {
  final int idUsuario;
  final String nmUsuarioAnfitriao;
  final String nmCardapio;
  final String dsCardapio;
  final int idRefeicao; // id_cardapio
  final int idEncontro; // id_encontro (para reserva)
  final DateTime hrEncontro;
  final int nuMaxConvidados;
  final int nuConvidadosConfirmados;
  final double precoRefeicao;
  final int idLocal;
  final String nuCep;
  final String nuCasa;
  final String? urlFoto;        // Foto do Prato
  final String? urlFotoAnfitriao; // Foto do Dono

  Cardapio({
    required this.idUsuario,
    required this.nmUsuarioAnfitriao,
    required this.nmCardapio,
    required this.dsCardapio,
    required this.idRefeicao,
    required this.idEncontro,
    required this.hrEncontro,
    required this.nuMaxConvidados,
    required this.nuConvidadosConfirmados, // <--- Adicionado no construtor
    required this.precoRefeicao,
    required this.idLocal,
    required this.nuCep,
    required this.nuCasa,
    this.urlFoto,
    this.urlFotoAnfitriao,
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
      dsCardapio: map['ds_cardapio']?.toString() ?? "",
      idRefeicao: _toInt(map['id_cardapio']), 
      
      // Garante ID do encontro (fallback para cardapio se nulo)
      idEncontro: map['id_encontro'] != null ? _toInt(map['id_encontro']) : _toInt(map['id_cardapio']),
      
      hrEncontro: DateTime.tryParse(map['hr_encontro'].toString()) ?? DateTime.now(),
      nuMaxConvidados: _toInt(map['nu_max_convidados']),
      
      // Mapeia o total de confirmados (vem da subquery no PHP)
      nuConvidadosConfirmados: _toInt(map['nu_convidados_confirmados']), 
      
      precoRefeicao: _toDouble(map['preco_refeicao']),
      idLocal: _toInt(map['id_local']),
      nuCep: map['nu_cep'].toString(),
      nuCasa: map['nu_casa'].toString(),
      urlFoto: map['vl_foto_cardapio']?.toString(), 
      
      // --- CORREÇÃO HÍBRIDA ---
      // Tenta ler 'vl_foto' (Reservas) OU 'vl_foto_usuario' (Home)
      urlFotoAnfitriao: map['vl_foto']?.toString() ?? map['vl_foto_usuario']?.toString(), 
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