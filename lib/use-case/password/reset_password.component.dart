import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/label-text.dart';
import 'package:hall_e_mobile/use-case/loader.component.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/validator.utils.dart';

class ResetPassword extends ConsumerStatefulWidget {
  final String? userId;
  final String token;

  const ResetPassword({super.key, required this.userId, required this.token});

  @override
  ConsumerState<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  FieldError _passwordError = noFieldError;
  FieldError _confirmPasswordError = noFieldError;
  PasswordStrength _strength = checkPasswordStrength('');
  bool _isValidated = false;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleObscure() => setState(() => _obscurePassword = !_obscurePassword);

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------
  bool _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _strength = (
          notUpper: true,
          notLower: true,
          notNumber: true,
          notSpecial: true,
          notLength: true,
        );
        _passwordError = fieldError('Ce champ est vide');
      });
      return false;
    }

    final strength = checkPasswordStrength(password);
    setState(() {
      _strength = strength;
      _passwordError = strength.isValid ? noFieldError : fieldError('');
    });
    return strength.isValid;
  }

  bool _validateConfirmPassword(String confirm) {
    final error = validateRequired(confirm, message: 'Le champ est vide');
    setState(() => _confirmPasswordError = error);
    return !error.hasError;
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------
  void _onSubmit() {
    setState(() {
      _isValidated = true;
      _passwordError = noFieldError;
      _confirmPasswordError = noFieldError;
    });

    final password = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    final validPassword = _validatePassword(password);
    final validConfirm = _validateConfirmPassword(confirm);

    if (validPassword && validConfirm && password != confirm) {
      const mismatch = 'Les mots de passe ne correspondent pas';
      setState(() {
        _passwordError = fieldError(mismatch);
        _confirmPasswordError = fieldError(mismatch);
      });
      return;
    }

    if (validPassword && validConfirm) {
      sendResetPassword(password);
    }
  }

  Future<void> sendResetPassword(String newPassword) async {
    final String? apiUrl = dotenv.env['API_URL'];

    setState(() => _isLoading = true);

    try {
      final Response response = await request(
        '$apiUrl/reset-password',
        data: {'id': widget.userId, 'newPassword': newPassword},
        'POST',
        token: widget.token,
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.pop(context, 'Mot de passe réinitialisé avec succès !');
      }
    } catch (e) {
      if (e is DioException && mounted) {
        await handleError(e, context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------------------
  Widget _buildPasswordRequirements() {
    Color ruleColor(bool failing) =>
        (_isValidated && failing) ? Colors.redAccent : textGold;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Le mot de passe doit contenir :',
              style: TextStyle(color: textGold, fontSize: 10)),
          for (final rule in passwordRules(_strength))
            Text(rule.label,
                style: TextStyle(color: ruleColor(rule.failing), fontSize: 10)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nouveau mot de passe
              LabeledTextField(
                icon: Icons.lock,
                label: 'Nouveau mot de passe',
                controller: newPasswordController,
                hasError: _passwordError.hasError,
                errorText: _passwordError.message,
                obscureText: _obscurePassword,
                onToggleObscure: _toggleObscure,
              ),
              _buildPasswordRequirements(),
              const SizedBox(height: 20),

              // Confirmation
              LabeledTextField(
                icon: Icons.lock,
                label: 'Confirmer le mot de passe',
                controller: confirmPasswordController,
                hasError: _confirmPasswordError.hasError,
                errorText: _confirmPasswordError.message,
                obscureText: _obscurePassword,
                onToggleObscure: _toggleObscure,
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? CustomLoader(text: 'Changement de mot de passe')
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: textGold,
                          foregroundColor: background),
                      onPressed: _onSubmit,
                      child: const Text('Changer votre mot de passe'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
