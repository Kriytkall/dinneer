import 'package:dinneer/service/http/HttpService.dart';

class UsuarioService {
  // Ajuste este endpoint se sua pasta no servidor for diferente
  static const endpoint = "usuario/UsuarioController.php";
  static final httpService = HttpService(); 

  UsuarioService();

  static Future<dynamic> getUsuarios() async {
    return await httpService.get(endpoint, "getUsuarios");
  }

   static Future<dynamic> login(String email, String senha) async {
    // O PHP UsuarioService.php lê $loginData['vl_email'] e $loginData['vl_senha']
    final body = {
      'vl_email': email,
      'vl_senha': senha,
    };
    // No PHP a operação é 'loginUsuario'
    return await httpService.post(endpoint, "loginUsuario", body: body);
  }

  static Future<dynamic> createUsuario(Map<String, dynamic> dados) async {
    // O PHP espera operação 'createUsuario' e campos como nu_cpf, nm_usuario...
    return await httpService.post(endpoint, "createUsuario", body: dados);
  }

  // --- NOVA FUNÇÃO ADICIONADA ---
  // Atualiza apenas a foto do perfil no banco de dados
  static Future<dynamic> atualizarFotoPerfil(dynamic idUsuario, String novaUrl) async {
    final body = {
      'id_usuario': idUsuario.toString(), // Garante que vá como string
      'vl_foto': novaUrl,
    };
    // Chama a operação 'atualizarFotoPerfil' que criamos no UsuarioController.php
    return await httpService.post(endpoint, "atualizarFotoPerfil", body: body);
  }
}