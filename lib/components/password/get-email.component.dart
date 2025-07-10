import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class GetEmail extends StatefulWidget {
  final Function(int) getState;
  final Function(String) getIdUser;

  GetEmail({required this.getState, required this.getIdUser});

  @override
  _GetEmailState createState() => _GetEmailState();
}

class _GetEmailState extends State<GetEmail> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future sendEmail(String email) async {
    _isLoading = true;

    String? apiUrl = dotenv.env['API_URL'];

    try {
      setState(() {
        _isLoading = true;
      });

      Response response =
          await request({'email': email}, '$apiUrl/forgot-password', 'post');

      if (response.statusCode == 200) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          widget.getState(1);
          widget.getIdUser(response.data['id']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        await Future.delayed(Duration(seconds: 1));
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  void _onSubmit() async {
    String email = _emailController.text;
    await sendEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Vous avez oublier votre mot de passe ?',
            style: TextStyle(fontSize: 16, color: secondaryColor)),
        Container(
          width: 250,
          margin: EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: secondaryColor),
                  Text('Votre email', style: TextStyle(color: secondaryColor)),
                ],
              ),
              TextField(
                controller: _emailController,
                cursorColor: secondaryColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: secondaryColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: secondaryColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _onSubmit,
          style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor, foregroundColor: primaryColor),
          child: _isLoading
              ? CustomLoader(text: 'Vérification')
              : Text(
                  "Vérifier mon émail",
                  style: TextStyle(fontSize: 20),
                ),
        ),
      ],
    );
  }
}
