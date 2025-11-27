import '../http/HttpService.dart';

class CardapioService {
  static const endpoint = "cardapio/cardapioController.php";
  static final httpService = HttpService();

  static Future<dynamic> getCardapiosDisponiveis() async {
    return await httpService.get(endpoint, "getCardapiosDisponiveis");
  }

  static Future<dynamic> createRefeicao(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "createRefeicao", body: dados);
  }
}

