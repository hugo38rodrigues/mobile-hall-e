import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/label-text.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/use-case/loader.component.dart';
import 'package:hall_e_mobile/use-case/password/forgot_password.component.dart';
import 'package:hall_e_mobile/utils/contact_mail.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';
import 'package:hall_e_mobile/utils/validator.utils.dart';

class Connexion extends ConsumerStatefulWidget {
  final VoidCallback getStateSession;
  const Connexion({super.key, required this.getStateSession});

  @override
  ConsumerState<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends ConsumerState<Connexion> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FieldError _emailError = noFieldError;
  FieldError _passwordError = noFieldError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final emailError = validateEmail(_emailController.text);
    final passwordError = validateRequired(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return !emailError.hasError && !passwordError.hasError;
  }

  Future<void> _login() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final apiUrl = dotenv.env['API_URL'];

    try {
      final loginResponse = await request(
        data: {
          'email': _emailController.text,
          'password': _passwordController.text
        },
        '$apiUrl/auth/connexion',
        'POST',
      ).timeout(const Duration(seconds: 10));

      if (loginResponse.statusCode != 200) return;

      final token = loginResponse.headers.value('Authorization');
      if (token == null) return;

      final profileResponse = await request(
        '$apiUrl/user',
        'GET',
        token: token,
      ).timeout(const Duration(seconds: 10));

      if (profileResponse.statusCode == 200) {
        final user = User.fromMap({'token': token, ...profileResponse.data});
        ref.read(accountProvider.notifier).setAccount(user);
        if (!mounted) return;
        showSuccessSnackBar(context, 'Connexion réussie !');
      }
    } on DioException catch (e) {
      if (mounted) await handleError(e, context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForgotPassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPassword()),
    );
    if (result != null && mounted) {
      showSuccessSnackBar(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final contentWidth = isTablet ? 420.0 : 300.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Connexion",
                textAlign: TextAlign.center,
                style: TextStyle(color: textGold, fontSize: 16),
              ),
              const SizedBox(height: 20),

              LabeledTextField(
                icon: Icons.person,
                label: 'Votre email',
                controller: _emailController,
                hasError: _emailError.hasError,
                errorText: _emailError.message,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 50),
              LabeledTextField(
                icon: Icons.lock,
                label: 'Votre mot de passe',
                controller: _passwordController,
                hasError: _passwordError.hasError,
                errorText: _passwordError.message,
                obscureText: _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              // Mot de passe oublié (aligné à droite, sous le champ)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: _openForgotPassword,
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(
                          color: textGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // Inscription
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: textGold),
                    children: [
                      const TextSpan(text: "Vous n'avez pas de compte ? "),
                      TextSpan(
                        text: "M'inscrire",
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: textGold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.getStateSession,
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton connexion
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: background, backgroundColor: textGold),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CustomLoader(text: 'Connexion')
                    : const Text("Me connecter",
                        style: TextStyle(fontSize: 20)),
              ),

              // Contact
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: textGold),
                    children: [
                      const TextSpan(text: "Un problème ? "),
                      TextSpan(
                        text: "Contactez-nous",
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: textGold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchEmail(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
