import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/components/password/forgot_password.component.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/contact_mail.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';

class Connexion extends ConsumerStatefulWidget {
  final VoidCallback getStateProfile;
  const Connexion({super.key, required this.getStateProfile});

  @override
  ConsumerState<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends ConsumerState<Connexion> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEmptyEmail = false;
  bool _isNotEmail = false;
  bool _isEmptyPassword = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _isEmptyEmail = email.isEmpty;
      _isNotEmail = email.isNotEmpty && !regexEmail.hasMatch(email);
      _isEmptyPassword = password.isEmpty;
    });

    return !_isEmptyEmail && !_isNotEmail && !_isEmptyPassword;
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
        '$apiUrl/connexion',
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

  InputDecoration _inputDecoration({String? errorText, Widget? suffixIcon}) {
    const radius = BorderRadius.all(Radius.circular(20));
    return InputDecoration(
      errorText: errorText,
      suffixIcon: suffixIcon,
      errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
      border: OutlineInputBorder(
          borderRadius: radius, borderSide: const BorderSide(color: textGold)),
      focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: textGold, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Colors.red, width: 2)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool hasError = false,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    final color = hasError ? Colors.red : textGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          style: const TextStyle(color: textWhite),
          controller: controller,
          cursorColor: textGold,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: _inputDecoration(
            errorText: errorText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final contentWidth = isTablet ? 420.0 : 300.0;

    final isErrorEmail = _isEmptyEmail || _isNotEmail;
    final errorEmail = _isEmptyEmail
        ? 'Ce champ est vide'
        : _isNotEmail
            ? 'Ce n\'est pas un email'
            : null;

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

              // Email
              _buildField(
                icon: Icons.person,
                label: 'Votre email',
                controller: _emailController,
                hasError: isErrorEmail,
                errorText: errorEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),

              // Password
              _buildField(
                icon: Icons.lock,
                label: 'Votre mot de passe',
                controller: _passwordController,
                hasError: _isEmptyPassword,
                errorText: _isEmptyPassword ? 'Ce champ est vide' : null,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: textGold,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
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
                          ..onTap = widget.getStateProfile,
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
                        text: "Contactez nous",
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
