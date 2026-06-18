// services/programation.service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hall_e_mobile/models/programmation-match.model.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';

class ProgrammationService {
  final String _apiUrl = dotenv.env['API_URL'] ?? '';

  Future<List<ProgrammationMatch>> fetchByBar(
      String barId, String token) async {
    final response = await request(
          '$_apiUrl/bar/$barId',
          'GET',
          token: token
        )
        .timeout(const Duration(seconds: 10));

    final List<dynamic> data = response.data as List;
    return data.map((e) => ProgrammationMatch.fromJson(e)).toList();
  }

  Future<void> deleteProgramation(
      String idMatch, String barId, String token) async {
      String url = '$_apiUrl/bar/$idMatch/$barId';
      await request(url, 'DELETE', token: token)
        .timeout(const Duration(seconds: 10));
  }
}
