import 'package:flutter/foundation.dart';
import '../http/HttpService.dart';

class LocalService {
  // Define o endpoint do Controller no PHP
  static const endpoint = "local/LocalController.php";
  static final httpService = HttpService();

  // --- BUSCAR MEUS LOCAIS (CORRIGIDO) ---
  static Future<dynamic> getMeusLocais(String idUsuario) async {
    debugPrint("LocalService: Buscando locais para o ID $idUsuario...");

    // CORREÇÃO: Passamos o id_usuario como parametro separado, não na string da operação
    return await httpService.get(
      endpoint, 
      "getMeusLocais", 
      queryParams: {
        "id_usuario": idUsuario,
      }
    );
  }

  // --- CRIAR NOVO LOCAL ---
  static Future<dynamic> createLocal(Map<String, dynamic> dados) async {
    debugPrint("LocalService: Criando local com dados: $dados");
    return await httpService.post(endpoint, "createLocal", body: dados);
  }

  // --- DELETAR LOCAL ---
  static Future<dynamic> deleteLocal(String idLocal) async {
    debugPrint("LocalService: Deletando local ID $idLocal...");
    final body = {'id_local': idLocal};
    return await httpService.post(endpoint, "deleteLocal", body: body);
  }
}