import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hall_e_mobile/components/bars-screen/bard-card.component.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/models/user.models.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class BarList extends StatefulWidget {
  @override
  _BarListState createState() => _BarListState();
}

class _BarListState extends State<BarList> {
  @override
  void initState() {
    super.initState();
    getBars();
  }

  late List bars = [];
  bool isLoading = false;

  Future<void> getBars() async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    isLoading = true;

    try {
      Response response = await dio.get('$apiUrl/client/').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/client/'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        List<User> barList = (response.data['data'] as List)
            .map((bar) => User.fromMap(bar))
            .toList(); // ✅ Convertir en List<User>
        setState(() {
          bars = barList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        // Appelle la fonction de gestion des erreurs
        handleError(e, context);
        isLoading = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Padding(
                padding: EdgeInsets.only(top: 500),
                child: CustomLoader(text: "Chargement des bars")))
        : Column(
            children: bars.map((bar) => BarCard(bar: bar)).toList(),
          );
  }
}
