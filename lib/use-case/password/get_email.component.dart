import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/use-case/loader.component.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class GetEmail extends ConsumerStatefulWidget {
  final Function(int) getState;
  final Function(String) getIdUser;
  final Function(String) getToken;

  const GetEmail({super.key, required this.getState, required this.getIdUser, required this.getToken});

  @override
  ConsumerState<GetEmail> createState() => _GetEmailState();
}

class _GetEmailState extends ConsumerState<GetEmail> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> sendEmail(String email) async {
    final String? apiUrl = dotenv.env['API_URL'];

    setState(() {
      _isLoading = true;
    });

    try {
      final Response response = await request(
        data: {'email': email},
        '$apiUrl/forgot-password',
        'POST',
      );

            if (response.statusCode == 200) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        widget.getIdUser(response.data['id']);
        widget.getToken(response.headers.value('authorization')!);
        widget.getState(1);
      }
    } catch (e) {
      if (e is DioException) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        await handleError(e, context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSubmit() async {
    final String email = _emailController.text.trim();
    await sendEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Vous avez oublié votre mot de passe ?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: textGold),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: textGold),
                  const SizedBox(width: 6),
                  Text('Votre email', style: TextStyle(color: textGold)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                cursorColor: textGold,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: textWhite),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: textGold),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: textGold, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _onSubmit,
          style: ElevatedButton.styleFrom(
              backgroundColor: textGold, foregroundColor: background),
          child: _isLoading
              ? CustomLoader(text: 'Vérification')
              : const Text("Vérifier mon email",
                  style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
