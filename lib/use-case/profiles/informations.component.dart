import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/use-case/loader.component.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';

typedef FieldError = ({bool hasError, String? message});

const FieldError _noError = (hasError: false, message: null);
FieldError _errorOf(String msg) => (hasError: true, message: msg);

class InformationsComponent extends ConsumerStatefulWidget {
  const InformationsComponent({super.key, required this.profile});

  final User profile;

  @override
  ConsumerState<InformationsComponent> createState() =>
      _InformationsComponentState();
}

class _InformationsComponentState extends ConsumerState<InformationsComponent> {
  // Controllers — toujours présents
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  // Controllers client
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  // Controllers bar
  late final TextEditingController _barNameController;
  late final TextEditingController _barAddressController;
  late final TextEditingController _barDescriptionController;

  late String _selectedRole;

  // Erreurs par champ
  FieldError _emailError = _noError;
  FieldError _passwordError = _noError;
  FieldError _firstNameError = _noError;
  FieldError _lastNameError = _noError;
  FieldError _barNameError = _noError;
  FieldError _addressError = _noError;

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _isClient => _selectedRole == 'client';

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.profile.role;
    _emailController = TextEditingController(text: widget.profile.email);
    _passwordController = TextEditingController();

    // Tous les controllers initialisés une seule fois
    // → pas de recréation lors du changement de rôle
    _firstNameController =
        TextEditingController(text: widget.profile.informations.firstName);
    _lastNameController =
        TextEditingController(text: widget.profile.informations.lastName);
    _barNameController =
        TextEditingController(text: widget.profile.informations.name);
    _barAddressController =
        TextEditingController(text: widget.profile.informations.address);
    _barDescriptionController =
        TextEditingController(text: widget.profile.informations.description);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _barNameController.dispose();
    _barAddressController.dispose();
    _barDescriptionController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    showSuccessSnackBar(context, message);
  }

  void _showError(String message) {
    if (!mounted) return;
    showErrorSnackBar(context, message);
  }

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------
  Future<void> _sendUpdateProfile(Map<String, dynamic> profile) async {
    final apiUrl = dotenv.env['API_URL'];
    setState(() => _isLoading = true);

    try {
      final response = await request('PUT', '$apiUrl/user/update-profile',
              data: {'userId': widget.profile.id, 'profile': profile},
              token: widget.profile.token)
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw DioException(
          requestOptions: RequestOptions(path: '$apiUrl/'),
          type: DioExceptionType.connectionTimeout,
          message: 'Timeout',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        ref.read(accountProvider.notifier).updateAccount({
          'email': data['email'],
          'information': data['informations'],
        });
        _showSuccess('Profil mis à jour avec succès');
      }
    } on DioException catch (e) {
      final msg = e.type == DioExceptionType.connectionTimeout
          ? 'Délai dépassé — vérifiez votre connexion'
          : e.response?.data?['message'] as String? ??
              'Une erreur est survenue';
      _showError(msg);
      if (mounted) await handleError(e, context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateEmail(String email) {
    final error = email.isEmpty || !regexEmail.hasMatch(email)
        ? _errorOf('Email invalide')
        : _noError;
    setState(() => _emailError = error);
    return !error.hasError;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) return true;

    String? msg;
    if (!regexLength8.hasMatch(password)) {
      msg = 'Minimum 8 caractères';
    } else if (!regexStringWithNumber.hasMatch(password)) {
      msg = 'Doit contenir un chiffre';
    } else if (!regexSpecialChar.hasMatch(password)) {
      msg = 'Doit contenir un caractère spécial';
    } else if (!regexUpperCase.hasMatch(password)) {
      msg = 'Doit contenir une majuscule';
    }

    final error = msg != null ? _errorOf(msg) : _noError;
    setState(() => _passwordError = error);
    return !error.hasError;
  }

  bool _validateClientInputs(String firstName, String lastName) {
    final fnError = !regexString.hasMatch(firstName)
        ? _errorOf('Prénom invalide — lettres uniquement')
        : _noError;
    final lnError = !regexString.hasMatch(lastName)
        ? _errorOf('Nom invalide — lettres uniquement')
        : _noError;
    setState(() {
      _firstNameError = fnError;
      _lastNameError = lnError;
    });
    return !fnError.hasError && !lnError.hasError;
  }

  bool _validateBarInputs(String name, String address) {
    final nameError = !regexString.hasMatch(name)
        ? _errorOf('Nom du bar invalide — lettres uniquement')
        : _noError;
    setState(() => _barNameError = nameError);
    if (nameError.hasError) return false;

    final parts = address.split(',');
    FieldError addrError = _noError;

    if (parts.length < 2) {
      addrError = _errorOf('Format attendu : rue, code postal ville');
    } else {
      final street = parts[0].trim();
      final secondPart = parts[1].trim();
      final spaceIndex = secondPart.indexOf(' ');

      if (!regexStreet.hasMatch(street)) {
        addrError = _errorOf('Rue invalide : numéro puis nom de rue');
      } else if (spaceIndex == -1) {
        addrError = _errorOf('Format attendu : code postal puis ville');
      } else {
        final postalCode = secondPart.substring(0, spaceIndex).trim();
        final city = secondPart.substring(spaceIndex + 1).trim();

        if (!regexPostalCode.hasMatch(postalCode)) {
          addrError = _errorOf('Code postal invalide');
        } else if (!regexCity.hasMatch(city)) {
          addrError = _errorOf('Ville invalide');
        }
      }
    }

    setState(() => _addressError = addrError);
    return !addrError.hasError;
  }

  void _submitData() {
    setState(() {
      _emailError = _passwordError = _firstNameError =
          _lastNameError = _barNameError = _addressError = _noError;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    bool isValid = _validateEmail(email) & _validatePassword(password);

    String firstName = '', lastName = '';
    String barName = '', address = '', description = '';

    if (_isClient) {
      firstName = _firstNameController.text;
      lastName = _lastNameController.text;
      isValid &= _validateClientInputs(firstName, lastName);
    } else {
      barName = _barNameController.text;
      address = _barAddressController.text;
      description = _barDescriptionController.text;
      isValid &= _validateBarInputs(barName, address);
    }

    if (!isValid) return;

    final roleProfile = _isClient
        ? {'firstName': firstName, 'lastName': lastName}
        : {'name': barName, 'address': address, 'description': description};

    setState(() => _passwordController.clear());

    _sendUpdateProfile({
      'email': email,
      'password': password,
      'role': _selectedRole,
      ...roleProfile,
    });
  }

  // ---------------------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------------------

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    FieldError error = _noError,
    bool readOnly = false,
    bool obscure = false,
    bool showToggle = false,
  }) {
    final color = error.hasError ? Colors.red : textGold;

    return TextFormField(
      style: TextStyle(color: textWhite),
      controller: controller,
      readOnly: readOnly,
      obscureText: obscure,
      cursorColor: color,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color),
        errorText: error.message,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: color, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: textGold,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }

  Widget _buildClientFields() => Column(
        children: [
          _buildField(
            controller: _firstNameController,
            label: 'Prénom',
            error: _firstNameError,
          ),
          const SizedBox(height: 15),
          _buildField(
            controller: _lastNameController,
            label: 'Nom',
            error: _lastNameError,
          ),
        ],
      );

  Widget _buildBarFields() => Column(
        children: [
          _buildField(
            controller: _barNameController,
            label: 'Nom du bar',
            error: _barNameError,
          ),
          const SizedBox(height: 20),
          _buildField(
            controller: _barAddressController,
            label: 'Adresse',
            error: _addressError,
          ),
          const SizedBox(height: 20),
          _buildField(
            controller: _barDescriptionController,
            label: 'Description',
          ),
        ],
      );

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Card(
      color: background,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: textGold),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vos informations',
                style: TextStyle(color: textGold, fontSize: 20)),
            const SizedBox(height: 15),

            _buildField(
              controller: _emailController,
              label: 'Email',
              error: _emailError,
            ),
            const SizedBox(height: 15),

            _buildField(
              controller: _passwordController,
              label: 'Changer votre mot de passe',
              error: _passwordError,
              obscure: _obscurePassword,
              showToggle: true,
            ),
            const SizedBox(height: 15),

            // Rôle — lecture seule, non focusable
            AbsorbPointer(
              child: _buildField(
                controller: TextEditingController(text: _selectedRole),
                label: 'Rôle',
                readOnly: true,
              ),
            ),
            const SizedBox(height: 15),

            // Champs dynamiques avec transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_selectedRole),
                child: _isClient ? _buildClientFields() : _buildBarFields(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: background,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: textGold, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? CustomLoader(text: 'Enregistrement en cours...')
                    : Text('Enregistrer les modifications',
                        style: TextStyle(color: textGold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
