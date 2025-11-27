import 'package:dinneer/service/http/HttpService.dart'; // Verifique se o caminho está certo

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
}