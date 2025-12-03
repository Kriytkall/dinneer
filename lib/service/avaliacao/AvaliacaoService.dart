import 'package:flutter/foundation.dart';
import '../http/HttpService.dart';

class AvaliacaoService {
  static const endpoint = "avaliacao/AvaliacaoController.php";
  static final httpService = HttpService();

  // Enviar uma nova avaliação (usado no Modal)
  static Future<dynamic> avaliar(int idUsuario, int idEncontro, int idTipoAvaliacao, double nota) async {
    return await httpService.post(
      endpoint, 
      "createAvaliacao",
      body: {
        "id_usuario": idUsuario.toString(),
        "id_encontro": idEncontro.toString(),
        "id_avaliacao": idTipoAvaliacao.toString(),
        "vl_avaliacao": nota.toInt().toString(), // Garante inteiro para o banco
      },
    );
  }

  // Buscar Média e Total de Avaliações de um Usuário (usado no Perfil)
  static Future<Map<String, dynamic>> getMediaUsuario(int idUsuario) async {
    debugPrint("--- AVALIACAO: Buscando média para o usuário ID $idUsuario ---");
    try {
      final resposta = await httpService.get(
        endpoint, 
        "getMediaUsuario", 
        queryParams: {"id_usuario": idUsuario.toString()}
      );
      
      debugPrint("--- AVALIACAO: Resposta do servidor: $resposta ---");

      if (resposta != null && resposta['dados'] != null) {
        // O PHP pode retornar uma lista com 1 objeto ou o objeto direto. Tratamos ambos.
        final dados = (resposta['dados'] is List) 
            ? (resposta['dados'] as List).first 
            : resposta['dados'];
            
        return {
          // Converte para double/int de forma segura, evitando erros de tipo
          "media": double.tryParse(dados['media'].toString()) ?? 0.0,
          "total": int.tryParse(dados['total'].toString()) ?? 0,
        };
      }
      return {"media": 0.0, "total": 0};
    } catch (e) {
      debugPrint("--- AVALIACAO: Erro ao buscar média: $e ---");
      return {"media": 0.0, "total": 0};
    }
  }
}