import '../http/HttpService.dart';

class RefeicaoService {
  static const endpoint = "refeicao/RefeicaoController.php";
  static final httpService = HttpService();

  static Future<dynamic> getRefeicoes() async {
    return await httpService.get(endpoint, "getRefeicoes");
  }

  static Future<dynamic> createRefeicao(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "createRefeicao", body: dados);
  }
}

