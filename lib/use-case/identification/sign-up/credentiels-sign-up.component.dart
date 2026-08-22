import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/label-text.dart';
import 'package:hall_e_mobile/models/user-credentiels.model.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/validator.utils.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class CredentielsSignUp extends StatefulWidget {
  const CredentielsSignUp({
    super.key,
    required this.getCredentiels,
    required this.goNext,
    required this.profile,
  });

  final void Function(UserCredentiels) getCredentiels;
  final void Function(int) goNext;
  final UserCredentiels profile;

  @override
  State<CredentielsSignUp> createState() => _CredentielsSignUpState();
}

class _CredentielsSignUpState extends State<CredentielsSignUp> {
  // Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  FieldError _emailError = noFieldError;
  FieldError _passwordError = noFieldError;
  FieldError _confirmPasswordError = noFieldError;
  PasswordStrength _strength = checkPasswordStrength('');

  // Role
  bool _isSelectedRole = true;
  String? _selectedRole = '';

  // Visibility
  bool _obscurePassword = true;

  bool _isValidated = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.profile.email);
    _passwordController = TextEditingController(text: widget.profile.password);
    _confirmPasswordController =
        TextEditingController(text: widget.profile.password);
    _selectedRole = widget.profile.role;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------
  bool _validateRole() {
    final valid = _selectedRole == 'client' || _selectedRole == 'bar';
    setState(() => _isSelectedRole = valid);
    return valid;
  }

  bool _validateEmail(String email) {
    final error = validateEmail(
      email,
      emptyMessage: 'Veuillez saisir un email',
      invalidMessage: 'Veuillez saisir un email valide',
    );
    setState(() => _emailError = error);
    return !error.hasError;
  }

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
        _passwordError = fieldError('');
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
  // Navigation
  // ---------------------------------------------------------------------------
  void _nextPage() {
    setState(() {
      _isValidated = true;
      _passwordError = noFieldError;
      _confirmPasswordError = noFieldError;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    final validEmail = _validateEmail(email);
    final validPassword = _validatePassword(password);
    final validConfirm = _validateConfirmPassword(confirm);
    final validRole = _validateRole();

    if (validPassword && validConfirm && password != confirm) {
      const mismatch = 'Les mots de passe ne correspondent pas';
      setState(() {
        _passwordError = fieldError(mismatch);
        _confirmPasswordError = fieldError(mismatch);
      });
      return;
    }

    if (validEmail && validPassword && validConfirm && validRole) {
      final credentials = UserCredentiels.fromJson(
          {'email': email, 'password': password, 'role': _selectedRole});
      widget.getCredentiels(credentials);
      widget.goNext(1);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  void _toggleObscure() => setState(() => _obscurePassword = !_obscurePassword);

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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              'Inscription',
              style: TextStyle(fontSize: 25, color: textGold),
            ),
          ),

          // Role selection
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleOption('Client', 'client'),
                    const SizedBox(width: 20),
                    _buildRoleOption('Bar', 'bar'),
                  ],
                ),
                if (!_isSelectedRole)
                  const Text('Veuillez sélectionner un rôle',
                      style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),

          // Email
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 300,
            child: LabeledTextField(
              icon: Icons.person,
              label: 'Votre email',
              controller: _emailController,
              hasError: _emailError.hasError,
              errorText: _emailError.message,
              keyboardType: TextInputType.emailAddress,
            ),
          ),

          // Mot de passe
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 300,
            child: Column(
              children: [
                LabeledTextField(
                  icon: Icons.lock,
                  label: 'Mot de passe',
                  controller: _passwordController,
                  hasError: _passwordError.hasError,
                  errorText: _passwordError.message,
                  obscureText: _obscurePassword,
                  onToggleObscure: _toggleObscure,
                ),
                _buildPasswordRequirements(),
              ],
            ),
          ),

          // Confirmation
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 300,
            child: LabeledTextField(
              icon: Icons.lock,
              label: 'Confirmer votre mot de passe',
              controller: _confirmPasswordController,
              hasError: _confirmPasswordError.hasError,
              errorText: _confirmPasswordError.message,
              obscureText: _obscurePassword,
              onToggleObscure: _toggleObscure,
            ),
          ),

          // Submit
          Container(
            margin: const EdgeInsets.all(20),
            width: 250,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: textGold, foregroundColor: background),
              onPressed: _nextPage,
              child: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String label, String value) {
    final color = _isSelectedRole ? textGold : Colors.redAccent;
    return Column(
      children: [
        Text(label, style: TextStyle(color: color)),
        Radio<String>(
          value: value,
          groupValue: _selectedRole,
          fillColor: WidgetStateProperty.all(color),
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
      ],
    );
  }
}
