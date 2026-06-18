import 'package:dio/dio.dart';

Future<Response> request(
  String url,
  String httpMethod, {
  String? token,
  Map<String, dynamic>? data,
}) async {
  Dio dio = Dio();
  
  try {
    final headers = {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };

    Response response;

    switch (httpMethod) {
      case 'GET':
        response = await dio.get(
          url,
          queryParameters: data,
          options: Options(headers: headers),
        );
        break;
      case 'POST':
        response = await dio.post(
          url,
          data: data,
          options: Options(headers: headers),
        );
        break;
      case 'PUT':
        response = await dio.put(
          url,
          data: data,
          options: Options(headers: headers),
        );
        break;
      case 'DELETE':
        response = await dio.delete(
          url,
          options: Options(headers: headers),
        );
        break;
      default:
        throw ArgumentError('Méthode HTTP non supportée: $httpMethod');
    }

    return response;
  } on DioException catch (e) {
    print("Erreur Dio : ${e.message}");
    rethrow;
  } catch (e) {
    print("Erreur inattendue : $e");
    rethrow;
  }
}
