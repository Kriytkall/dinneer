import 'package:dinneer/service/http/HTTPService.dart';

class UsuarioService {
  static const endpoint = "usuario/UsuarioController.php";
  static final httpService = HttpService(); 

  UsuarioService();

  static Future<dynamic> getUsuarios() async {
    return await httpService.get(endpoint, "getUsuarios");
  }

   static Future<dynamic> login(String email, String senha) async {
    final body = {
      'email': email,
      'senha': senha,
    };
    return await httpService.post(endpoint, "login", body: body);
  }

}
