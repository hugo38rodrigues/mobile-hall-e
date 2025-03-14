import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class SendCode extends StatefulWidget {
  final Function(int) getState;
  final String idUser;

  SendCode({required this.getState, required this.idUser});

  @override
  _SendCodeState createState() => _SendCodeState();
}

class _SendCodeState extends State<SendCode> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future sendCode(String code) async {
    try {
      Response response = await request({'idUser': widget.idUser, 'code': code},
          '$apiUrl/commun/verify-code', 'post');
      if (response.statusCode == 200) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          widget.getState(2);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _isLoading = false;
        });
        // Appelle la fonction de gestion des erreurs
        handleError(e, context);
      }
    }
  }

  void _onSubmit() async {
    String code = _codeController.text;

    await sendCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Veulliez entrer le code de vérification que vous avez reçus',
          style: TextStyle(color: secondaryColor),
        ),
        SizedBox(height: 25),
        TextField(
          controller: _codeController,
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
        SizedBox(height: 25),
        ElevatedButton(
          onPressed: _onSubmit,
          style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor, foregroundColor: primaryColor),
          child: _isLoading
              ? CustomLoader(text: 'Vérification')
              : Text(
                  "Envoyer votre code",
                  style: TextStyle(fontSize: 20),
                ),
        )
      ],
    );
  }
}
