import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Import para debugPrint

class HttpService {
  // CORREÇÃO FINAL: A URL agora aponta para a sua pasta 'pdm_php'.
  String baseUrl = "http://192.168.1.201/pdm_php/api/v1/";

  HttpService();

  Future<dynamic> post(String endpoint, String operacao, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint?oper=$operacao");

    debugPrint("--------------------");
    debugPrint("POST Request URL: $url");
    debugPrint("Request Body: ${jsonEncode(body)}");

    try {
      final requestBody = {
        'dados': jsonEncode(body),
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: requestBody,
        encoding: Encoding.getByName('utf-8'),
      );
      
      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      debugPrint("--------------------");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro na API: ${response.statusCode}. Resposta: ${response.body}');
      }
    } catch (e) {
      debugPrint("Falha na requisição: $e");
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<dynamic> get(String endpoint, String operacao) async {
    final url = Uri.parse("$baseUrl$endpoint?oper=$operacao");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}

