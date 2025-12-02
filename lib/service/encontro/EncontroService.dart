import '../http/HttpService.dart';

class EncontroService {
  static const endpoint = "encontro/EncontroController.php";
  static final httpService = HttpService();

  // Função para fazer a reserva
  static Future<dynamic> reservar(int idUsuario, int idEncontro, int dependentes) async {
    return await httpService.post(
      endpoint, 
      "addUsuarioEncontro", // Nome da operação no seu PHP Controller
      body: {
        "id_usuario": idUsuario.toString(),
        "id_encontro": idEncontro.toString(),
        "nu_dependentes": dependentes.toString(),
      },
    );
  }

  // Busca as reservas feitas pelo usuário
  static Future<dynamic> getMinhasReservas(int idUsuario) async {
    return await httpService.get(
      endpoint, 
      "getMinhasReservas", 
      queryParams: {
        "id_usuario": idUsuario.toString(),
      }
    );
  }

  // Busca os jantares criados pelo usuário
  static Future<dynamic> getMeusJantaresCriados(int idUsuario) async {
    return await httpService.get(
      endpoint, 
      "getMeusJantaresCriados", 
      queryParams: {
        "id_usuario": idUsuario.toString(),
      }
    );
  }
}