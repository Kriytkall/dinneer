import '../http/HttpService.dart';

class CardapioService {
  static const endpoint = "cardapio/CardapioController.php";
  static final httpService = HttpService();

  static Future<dynamic> getCardapiosDisponiveis() async {
    return await httpService.get(endpoint, "getCardapiosDisponiveis");
  }

  static Future<dynamic> createJantar(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "createJantar", body: dados);
  }
}