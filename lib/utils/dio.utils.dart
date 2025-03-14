import 'package:dio/dio.dart';

Future<Response> request(
    Map<String, dynamic> data, String url, String httpMethod) async {
  Dio dio = Dio();

  try {
    Response response;

    switch (httpMethod.toUpperCase()) {
      case 'GET':
        response = await dio.get(url, queryParameters: data);
        break;
      case 'POST':
        response = await dio.post(url, data: data);
        break;
      case 'PUT':
        response = await dio.put(url, data: data);
        break;
      case 'DELETE':
        response = await dio.delete(url, data: data);
        break;
      default:
        throw ArgumentError('Méthode HTTP non supportée: $httpMethod');
    }

    return response;
  } on DioException catch (e) {
    print("Erreur Dio : ${e.message}");
    rethrow; // Propage l'erreur pour la gestion en amont
  } catch (e) {
    print("Erreur inattendue : $e");
    rethrow;
  }
}
