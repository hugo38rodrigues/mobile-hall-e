import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hall_e_mobile/components/identification/bar-information.dart';
import 'package:hall_e_mobile/components/identification/client-information.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/user-credentiels.model.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:provider/provider.dart';

class InformationsSignUp extends StatefulWidget {
  final Function(int) goBack;
  final Function getStateProfile;
  final UserCredentiels credentiels;
  InformationsSignUp(
      {required this.credentiels,
      required this.goBack,
      required this.getStateProfile});

  @override
  _InformationsSignUpState createState() => _InformationsSignUpState();
}

class _InformationsSignUpState extends State<InformationsSignUp> {

  Informations? informations;

  void getInformations(newInformations) {
    setState(() {
      informations = newInformations;
    });
  }

  Widget fieldsInformation(role) {
    switch (role) {
      case 'client':
        return ClientInformations(getInformations: getInformations);

      case 'bar':
      return BarInformations(getInformation: getInformations);

      default:
        return Text(
          'Role non définis',
          style: TextStyle(color: secondaryColor, fontSize: 15),
        );
    }
  }

  Future<void> sendSignUp(informations, credentiels) async {

    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .post('$apiUrl/sign-up',
              data: {
                'email': credentiels.email,
                'password': credentiels.password,
                'role': credentiels.role,
                'informations':informations
              },
              options: Options(
                headers: {"Content-Type": "application/json"},
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/sign-up'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 201) {
        widget.getStateProfile();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;
        await handleError(e, context);
      }
    }
  }

  void onSubmit() {
    sendSignUp(informations, widget.credentiels);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              fieldsInformation(widget.credentiels.role),
              SizedBox(
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.goBack(0);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: primaryColor),
                      child: Text('Retour'),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    ElevatedButton(
                      onPressed: () => onSubmit(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: primaryColor),
                      child: Text('S\'inscrire'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
