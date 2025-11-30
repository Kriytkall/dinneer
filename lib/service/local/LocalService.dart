import '../http/HttpService.dart';

class LocalService {
  static const endpoint = "local/LocalController.php";
  static final httpService = HttpService();

  static Future<dynamic> createLocal(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "createLocal", body: dados);
  }

  static Future<dynamic> getMeusLocais(String idUsuarioLogado) async {
    const operacao = "getMeusLocais";

    return await httpService.get(
      endpoint,
      operacao,
      queryParams: {
        "id_usuario": idUsuarioLogado,
      },
    );
  }

  static Future<dynamic> deleteLocal(String idLocal) async {
    return await httpService.post(
      endpoint,
      "deleteLocal",
      body: {
        "id_local": idLocal,
      },
    );
  }
}