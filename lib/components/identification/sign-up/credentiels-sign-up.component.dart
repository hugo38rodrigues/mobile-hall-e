import 'package:flutter/material.dart';
import 'package:hall_e_mobile/models/user-credentiels.model.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';

// ---------------------------------------------------------------------------
// Model helper – groups an error flag and its message
// ---------------------------------------------------------------------------
typedef FieldError = ({bool hasError, String? message});

const FieldError _noError = (hasError: false, message: null);
FieldError _errorOf(String msg) => (hasError: true, message: msg);

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

  // Field errors
  FieldError _emailError = _noError;
  FieldError _passwordError = _noError;
  FieldError _confirmPasswordError = _noError;

  // Password-strength flags
  bool _isNotUpper = false;
  bool _isNotLower = false;
  bool _isNotNumber = false;
  bool _isNotSpecialChar = false;
  bool _isNotEightMinimal = false;

  // Role
  bool _isSelectedRole = true;
  String? _selectedRole = '';

  // Visibility
  bool _obscurePassword = true;

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
    FieldError error;
    if (email.isEmpty) {
      error = _errorOf('Veuillez saisir un email');
    } else if (!regexEmail.hasMatch(email)) {
      error = _errorOf('Veuillez saisir un email valide');
    } else {
      error = _noError;
    }
    setState(() => _emailError = error);
    return !error.hasError;
  }

  bool _validatePasswordStrength(String password) {
    final notUpper = !regexUpperCase.hasMatch(password);
    final notLower = !regexLowercase.hasMatch(password);
    final notNumber = !regexStringWithNumber.hasMatch(password);
    final notSpecial = !regexSpecialChar.hasMatch(password);
    final notLength = !regexLength8.hasMatch(password);

    setState(() {
      _isNotUpper = notUpper;
      _isNotLower = notLower;
      _isNotNumber = notNumber;
      _isNotSpecialChar = notSpecial;
      _isNotEightMinimal = notLength;
    });

    return !(notUpper || notLower || notNumber || notSpecial || notLength);
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _isNotUpper = _isNotLower =
            _isNotNumber = _isNotSpecialChar = _isNotEightMinimal = true;
        _passwordError = _errorOf('');
      });
      return false;
    }

    final strong = _validatePasswordStrength(password);
    setState(() {
      _passwordError = strong ? _noError : _errorOf('');
    });
    return strong;
  }

  bool _validateConfirmPassword(String confirm) {
    FieldError error;
    if (confirm.isEmpty) {
      error = _errorOf('Le champ est vide');
    } else {
      error = _noError;
    }
    setState(() => _confirmPasswordError = error);
    return !error.hasError;
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------
  void _nextPage() {
    setState(() {
      _passwordError = _noError;
      _confirmPasswordError = _noError;
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
        _passwordError = _errorOf(mismatch);
        _confirmPasswordError = _errorOf(mismatch);
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

  /// Reusable decorated [TextField].
  Widget _buildTextField({
    required TextEditingController controller,
    required bool hasError,
    required String? errorText,
    bool obscure = false,
    bool showToggle = false,
  }) {
    final border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: textGold),
    );
    final errorBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.red, width: 2),
    );

    return TextField(
      style: TextStyle(color: textWhite),
      controller: controller,
      cursorColor: textGold,
      obscureText: obscure,
      decoration: InputDecoration(
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: textGold,
                ),
                onPressed: _toggleObscure,
              )
            : null,
        border: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: textGold, width: 2),
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  /// Row label above a field.
  Widget _buildFieldLabel(String label, bool hasError) {
    final color = hasError ? Colors.redAccent : textGold;
    return Row(
      children: [
        Icon(Icons.person, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  /// Password-strength checklist.
  Widget _buildPasswordRequirements() {
    Color ruleColor(bool failing) => failing ? Colors.redAccent : textGold;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Le mot de passe doit contenir :',
              style: TextStyle(color: textGold, fontSize: 10)),
          Text('- Une majuscule',
              style: TextStyle(color: ruleColor(_isNotUpper), fontSize: 10)),
          Text('- Une minuscule',
              style: TextStyle(color: ruleColor(_isNotLower), fontSize: 10)),
          Text('- Un chiffre',
              style: TextStyle(color: ruleColor(_isNotNumber), fontSize: 10)),
          Text('- Un caractère spécial',
              style:
                  TextStyle(color: ruleColor(_isNotSpecialChar), fontSize: 10)),
          Text('- Minimum 8 caractères',
              style: TextStyle(
                  color: ruleColor(_isNotEightMinimal), fontSize: 10)),
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
          // Title
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: Text('Bienvenue sur Ezone',
                style: TextStyle(fontSize: 25, color: textGold)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text('Inscription',
                style: TextStyle(fontSize: 15, color: textGold)),
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
            child: Column(
              children: [
                _buildFieldLabel('Votre email', _emailError.hasError),
                _buildTextField(
                  controller: _emailController,
                  hasError: _emailError.hasError,
                  errorText: _emailError.message,
                ),
              ],
            ),
          ),

          // Password
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 300,
            child: Column(
              children: [
                _buildFieldLabel('Mot de passe', _passwordError.hasError),
                _buildTextField(
                  controller: _passwordController,
                  hasError: _passwordError.hasError,
                  errorText: _passwordError.message,
                  obscure: _obscurePassword,
                  showToggle: true,
                ),
                _buildPasswordRequirements(),
              ],
            ),
          ),

          // Confirm password
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 300,
            child: Column(
              children: [
                _buildFieldLabel('Confirmer votre mot de passe',
                    _confirmPasswordError.hasError),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hasError: _confirmPasswordError.hasError,
                  errorText: _confirmPasswordError.message,
                  obscure: _obscurePassword,
                  showToggle: true,
                ),
              ],
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
