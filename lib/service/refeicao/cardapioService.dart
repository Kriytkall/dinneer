import '../http/HttpService.dart';

class CardapioService {
  static const endpoint = "cardapio/CardapioController.php";
  static final httpService = HttpService();

  static Future<dynamic> createJantar(Map<String, dynamic> dados) async {
    return await httpService.post(endpoint, "createJantar", body: dados);
  }

  static Future<dynamic> getCardapiosDisponiveis() async {
    final resposta = await httpService.get(endpoint, "getCardapiosDisponiveis");
    
    // --- ADICIONE ESTA LINHA AQUI ---
    print("DEBUG HOME: $resposta"); 
    // --------------------------------
    
    return resposta;
  }

  static Future<dynamic> getMeuCardapio(int idLocal) async {
    return await httpService.get(
      endpoint, 
      "getMeuCardapio",       
      queryParams: {
        "id_local": idLocal.toString(),
      }
    );
  }

  static Future<dynamic> deleteJantar(int idJantar) async {
    return await httpService.post(
      endpoint,
      "deleteCardapio",
      body: {
        "id_cardapio": idJantar.toString(),
      },
    );
  }
}