import '../http/HttpService.dart';

class EncontroService {
  static const endpoint = "encontro/EncontroController.php";
  static final httpService = HttpService();

  // Fazer reserva
  static Future<dynamic> reservar(int idUsuario, int idEncontro, int dependentes) async {
    return await httpService.post(
      endpoint, 
      "addUsuarioEncontro",
      body: {
        "id_usuario": idUsuario.toString(),
        "id_encontro": idEncontro.toString(),
        "nu_dependentes": dependentes.toString(),
      },
    );
  }

  // Cancelar reserva
  static Future<dynamic> cancelarReserva(int idUsuario, int idEncontro) async {
    return await httpService.post(
      endpoint, 
      "deleteUsuarioEncontro",
      body: {
        "id_usuario": idUsuario.toString(),
        "id_encontro": idEncontro.toString(),
      },
    );
  }

  // Verificar status
  static Future<bool> verificarSeJaReservei(int idUsuario, int idEncontro) async {
    try {
      final resposta = await httpService.get(
        endpoint, 
        "verificarReserva",
        queryParams: {
          "id_usuario": idUsuario.toString(),
          "id_encontro": idEncontro.toString(),
        }
      );
      // Se retornou registro (registros > 0), é porque reservou
      if (resposta != null && (resposta['registros'] as int) > 0) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> getMinhasReservas(int idUsuario) async {
    return await httpService.get(endpoint, "getMinhasReservas", queryParams: {"id_usuario": idUsuario.toString()});
  }

  static Future<dynamic> getMeusJantaresCriados(int idUsuario) async {
    return await httpService.get(endpoint, "getMeusJantaresCriados", queryParams: {"id_usuario": idUsuario.toString()});
  }
}