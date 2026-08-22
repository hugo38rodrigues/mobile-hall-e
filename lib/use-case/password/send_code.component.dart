import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/use-case/loader.component.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class SendCode extends ConsumerStatefulWidget {
  final Function(int) getState;
  final String? userId;
  final String? token;

  SendCode({required this.getState, required this.userId, required this.token});

  @override
  _SendCodeState createState() => _SendCodeState();
}

class _SendCodeState extends ConsumerState<SendCode> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future sendCode(String code) async {
    String? apiUrl = dotenv.env['API_URL'];
    try {
      Response response = await request(
          data: {'userId': widget.userId, 'code': code},
          '$apiUrl/verify-code',
          'POST',
          token: widget.token);
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
        if (!mounted) return;

        await handleError(e, context);

        if (!mounted) return; // Vérifie encore après un await
        setState(() => _isLoading = false);
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
          'Veuillez entrer le code de vérification que vous avez reçus',
          style: TextStyle(color: textGold),
        ),
        SizedBox(height: 25),
        TextField(
          controller: _codeController,
          cursorColor: textGold,
          style: TextStyle(color: textGold),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: textGold)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: textGold, width: 2),
            ),
          ),
        ),
        SizedBox(height: 25),
        ElevatedButton(
          onPressed: _onSubmit,
          style: ElevatedButton.styleFrom(
              backgroundColor: textGold, foregroundColor: background),
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
