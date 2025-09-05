import 'package:dinneer/service/http/HTTPService.dart';

class UsuarioService {
  static const endpoint = "/usuario/UsuarioController.php";
  static final httpService = HttpService(); 

  UsuarioService();

  static Future<dynamic> getUsuarios() async {
    return await httpService.get(endpoint, "getUsuarios");
  }
}
