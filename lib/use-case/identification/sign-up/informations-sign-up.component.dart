import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/user-credentiels.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/use-case/identification/bar_information.dart';
import 'package:hall_e_mobile/use-case/identification/client_information.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';

class InformationsSignUp extends ConsumerStatefulWidget {
  final Function(int) goBack;
  final Function getStateSession;
  final UserCredentiels credentiels;

  const InformationsSignUp({
    super.key,
    required this.credentiels,
    required this.goBack,
    required this.getStateSession,
  });

  @override
  ConsumerState<InformationsSignUp> createState() => _InformationsSignUpState();
}

class _InformationsSignUpState extends ConsumerState<InformationsSignUp> {
  Informations? informations;
  bool _isLoading = false;

  void getInformations(Informations? newInformations) {
    setState(() {
      informations = newInformations;
    });
  }

  Widget fieldsInformation(String role) {
    switch (role) {
      case 'client':
        return ClientInformations(getInformations: getInformations);
      case 'bar':
        return BarInformations(getInformation: getInformations);
      default:
        return const Text(
          'Rôle non défini',
          style: TextStyle(color: textGold, fontSize: 15),
        );
    }
  }

  Future<void> sendRegister(
      Informations? informations, UserCredentiels credentiels) async {
    final String token = ref.read(accountProvider).token;
    final String? apiUrl = dotenv.env['API_URL'];

    setState(() {
      _isLoading = true;
    });

    try {
      final Response response = await request(
        data: {
          'email': credentiels.email,
          'password': credentiels.password,
          'role': credentiels.role,
          'informations': informations,
        },
        '$apiUrl/auth/register',
        'POST',
        token: token,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/registe'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        showSuccessSnackBar(context, 'Inscription réussie !');
        widget.getStateSession();
      }
    } catch (e) {
      if (e is DioException) {
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

  void onSubmit() {
    sendRegister(informations, widget.credentiels);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double contentWidth = isTablet ? 400 : 320;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              fieldsInformation(widget.credentiels.role),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => widget.goBack(0),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: textGold, foregroundColor: background),
                    child: const Text('Retour'),
                  ),
                  const SizedBox(width: 50),
                  ElevatedButton(
                    onPressed: _isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: textGold, foregroundColor: background),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: background),
                          )
                        : const Text("S'inscrire"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
