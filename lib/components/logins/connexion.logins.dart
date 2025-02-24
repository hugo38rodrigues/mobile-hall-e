import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class Connexion extends StatefulWidget {
  final Function getStateProfile;
  Connexion({required this.getStateProfile});

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmptyEmail = false;
  bool _isNotEmail = false;
  bool _isEmptyPassword = false;
  String _errorEmptyFieldMessage = 'Ce champ est vide';
  String _errorNotEmailMessage = 'Ce n\'est pas un email';
  bool _isLoading = false;

  bool _verifyEmptyFiled(String value) {
    if (value.isEmpty) {
      return true;
    }
    return false;
  }

  bool _isValidEmail(String email) {
    final RegExp regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return regex.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    _isEmptyEmail = false;
    _isNotEmail = false;
    _isEmptyPassword = false;
    _isLoading = false;
  }

  bool _isValidFormData(String email, String password) {
    bool isValidFormData = true;
    bool emailIsEmpty = _verifyEmptyFiled(email);
    bool passwordIsEmpty = _verifyEmptyFiled(password);
    _isEmptyEmail = false;
    _isNotEmail = false;
    _isEmptyPassword = false;

    if (emailIsEmpty) {
      _isEmptyEmail = true;
      isValidFormData = false;
    }

    if (passwordIsEmpty) {
      _isEmptyPassword = true;
      isValidFormData = false;
    }

    bool isEmail = _isValidEmail(email);

    if (!isEmail) {
      _isNotEmail = true;
      isValidFormData = false;
    }
    return isValidFormData;
  }

  Future<void> getConnexion(ref, email, password) async {
    _isLoading = true;
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response profile = await dio.post('$apiUrl/commun/connexion',
          data: {"email": email, "password": password},
          options: Options(
            headers: {"Content-Type": "application/json"},
          ));

      ref.read(accountProvider.notifier).setAccount(profile.data);

    } catch (e) {
      print('Erreur : $e');
      _isLoading = true;
    }
  }

  void _submitText(WidgetRef ref) {
    setState(() {
      String email =
          _emailController.text; // Récupération de la valeur du champ de texte
      String password = _passwordController.text;

      bool isValidFormData = _isValidFormData(email, password);
      if (isValidFormData) {
        getConnexion(ref, email, password);

        _isEmptyPassword = false;
        _isEmptyEmail = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isErrorEmail = _isEmptyEmail || _isNotEmail;
    String? errorMessageEmail = _isEmptyEmail
        ? _errorEmptyFieldMessage
        : _isNotEmail
            ? _errorNotEmailMessage
            : null;
    return Consumer(
      builder: (context, ref, child) {
        return Column(children: [
          SizedBox(height: 40),
          Text(
            "Bon retour parmi nous !",
            style: TextStyle(color: secondaryColor, fontSize: 24),
          ),
          SizedBox(height: 40),
          Text(
            "Connexion",
            style: TextStyle(color: secondaryColor, fontSize: 16),
          ),
          SizedBox(height: 20),
          SizedBox(
              width: 250,
              height: 120,
              child: Column(children: [
                Row(children: [
                  Icon(Icons.person,
                      color: isErrorEmail ? Colors.red : secondaryColor),
                  Text('Votre email',
                      style: TextStyle(
                          color: isErrorEmail ? Colors.red : secondaryColor))
                ]),
                TextField(
                  controller: _emailController,
                  cursorColor: secondaryColor,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: secondaryColor)),
                    errorText: errorMessageEmail,
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 14), // Couleur du texte d'erreur
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: secondaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                          color: Colors.red,
                          width: 2), // Bordure rouge en cas d'erreur
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                          color: Colors.redAccent,
                          width:
                              2), // Bordure accentuée en cas d'erreur et focus
                    ),
                  ),
                ),
              ])),
          SizedBox(
              width: 250,
              height: _isEmptyPassword ? 120 : 90,
              child: Column(children: [
                Row(children: [
                  Icon(Icons.person,
                      color: _isEmptyPassword ? Colors.red : secondaryColor),
                  Text('Votre password',
                      style: TextStyle(
                          color:
                              _isEmptyPassword ? Colors.red : secondaryColor)),
                ]),
                TextField(
                  controller: _passwordController,
                  cursorColor: secondaryColor,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: secondaryColor)),
                    errorText:
                        _isEmptyPassword ? _errorEmptyFieldMessage : null,
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 14), // Couleur du texte d'erreur
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: secondaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                          color: Colors.red,
                          width: 2), // Bordure rouge en cas d'erreur
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                          color: Colors.redAccent,
                          width:
                              2), // Bordure accentuée en cas d'erreur et focus
                    ),
                  ),
                ),
              ])),
          SizedBox(height: 50),
          SizedBox(
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: primaryColor,
                    backgroundColor: secondaryColor),
                onPressed: () => _submitText(ref), // Passe `ref` ici
                child: _isLoading
                    ? CustomLoader(text: 'Connection')
                    : Text(
                        "Me connecter",
                        style: TextStyle(fontSize: 20),
                      ),
              )),
        ]);
      },
    );
  }
}
