import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  String baseUrl = "http://10.0.2.2/pdm_php/api/v1/";

  HttpService();

  Future<dynamic> post(String endpoint, String operacao, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint?operacao=$operacao");

    try {
      final requestBody = {
        "oper": operacao,
        ...?body,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<dynamic> get(String endpoint, String operacao) async {
    final url = Uri.parse("$baseUrl$endpoint?operacao=$operacao");

    try {

      final response = await http.get(url);

      if (response.statusCode == 200) {
        print(response.body);
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

}
