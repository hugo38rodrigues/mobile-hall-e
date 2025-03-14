import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/user-credentiels.model.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';

class CredentielsSignUp extends StatefulWidget {
  final Function(UserCredentiels) getCredentiels;
  final Function(int) goNext;
  final UserCredentiels profile;
  CredentielsSignUp(
      {required this.getCredentiels,
      required this.goNext,
      required this.profile});
  @override
  _CredentielsSignUpState createState() => _CredentielsSignUpState();
}

class _CredentielsSignUpState extends State<CredentielsSignUp> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  String? errorEmailMessage;
  String? errorPasswordMessage;
  String? errorConfirmPasswordMessage;
  bool isEmailError = false;
  bool isPasswordError = false;
  bool isConfirmPasswordError = false;
  bool isNotUpper = false;
  bool isNotLower = false;
  bool isNotNumber = false;
  bool isNotSpecialChar = false;
  bool isNotEightMinimal = false;
  bool isSelectedRole = true;
  String? selectedRole = '';

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.profile.email);
    passwordController = TextEditingController(text: widget.profile.password);
    confirmPasswordController =
        TextEditingController(text: widget.profile.password);
    selectedRole = widget.profile.role;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _setEmailError(String message) {
    errorEmailMessage = message;
    isEmailError = true;
  }

  void _clearEmailError() {
    errorEmailMessage = null;
    isEmailError = false;
  }

  void _setPasswordError(String message) {
    errorPasswordMessage = message;
    isPasswordError = true;
  }

  void _clearPasswordError() {
    errorPasswordMessage = null;
    isPasswordError = true;
  }

  void _setConfirmPasswordError(String message) {
    errorConfirmPasswordMessage = message;
    isConfirmPasswordError = true;
  }

  void _clearConfirmPasswordError() {
    errorConfirmPasswordMessage = null;
    isConfirmPasswordError = true;
  }

  bool checkRole() {
    if (selectedRole == 'client' || selectedRole == 'bar') {
      setState(() {
        isSelectedRole = true;
      });
      return true;
    }
    setState(() {
      isSelectedRole = false;
    });
    return false;
  }

  bool isValidEmail(String email) {
    if (email.isEmpty) {
      setState(() {
        _setEmailError('Veuillez saisir un email');
      });
      return false;
    } else if (!regexEmail.hasMatch(email)) {
      setState(() {
        _setEmailError('Veuillez saisir un email valide');
      });
      return false;
    }
    setState(() {
      _clearEmailError();
    });
    return true;
  }

  bool isValidStrengthPassword(String password) {
    setState(() {
      isNotEightMinimal = !regexLength8.hasMatch(password);
      isNotLower = !regexLowercase.hasMatch(password);
      isNotSpecialChar = !regexSpecialChar.hasMatch(password);
      isNotNumber = !regexStringWithNumber.hasMatch(password);
      isNotUpper = !regexUpperCase.hasMatch(password);
    });

    bool isValid = !(isNotEightMinimal ||
        isNotLower ||
        isNotSpecialChar ||
        isNotNumber ||
        isNotUpper);

    if (!isValid) {
      setState(() {
        isPasswordError = true;
      });
    }

    return isValid;
  }

  bool isValidConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      setState(() {
        _setConfirmPasswordError('Le champ est vide');
      });
      return false;
    }
    setState(() {
      isConfirmPasswordError = false;
    });
    return true;
  }

  bool validatePasswords(String password) {
    if (password.isEmpty) {
      setState(() {
        isNotEightMinimal = true;
        isNotLower = true;
        isNotSpecialChar = true;
        isNotNumber = true;
        isNotUpper = true;
        isPasswordError = true;
      });
      return false;
    }

    if (!isValidStrengthPassword(password)) {
      setState(() {
        isPasswordError = true;
      });
      return false;
    }

    setState(() {
      _clearPasswordError();
    });
    return true;
  }

  void nextPage() {
    setState(() {
      _clearPasswordError();
      _clearConfirmPasswordError();
    });
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    bool validEmail = isValidEmail(email);
    bool validPassword = validatePasswords(password);
    bool validConfirmPassword = isValidConfirmPassword(confirmPassword);
    bool validRole = checkRole();

    if (validPassword && validConfirmPassword && password != confirmPassword) {
      setState(() {
        _setPasswordError('Les mots de passe ne correspondent pas');
        _setConfirmPasswordError('Les mots de passe ne correspondent pas');
      });
      return;
    }

    if (validPassword && validConfirmPassword && validRole && validEmail) {
      UserCredentiels credentiels = UserCredentiels.fromJson(
          {'password': password, 'role': selectedRole, 'email': email});
      widget.getCredentiels(credentiels);
      widget.goNext(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SingleChildScrollView(
          // Ajout du scroll
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Text(
                  'Bienvenue sur Ezone',
                  style: TextStyle(fontSize: 25, color: secondaryColor),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  'Inscription',
                  style: TextStyle(fontSize: 15, color: secondaryColor),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Centre les éléments
                      children: [
                        Column(
                          children: [
                            Text(
                              "Client",
                              style: TextStyle(
                                  color: isSelectedRole
                                      ? secondaryColor
                                      : Colors.redAccent),
                            ), // Texte au-dessus
                            Radio<String>(
                              value: 'client', // Couleur lorsque sélectionné
                              fillColor: WidgetStateProperty.all(isSelectedRole
                                  ? secondaryColor
                                  : Colors.redAccent),
                              groupValue: selectedRole,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedRole = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                            width: 20), // Espacement entre les deux boutons
                        Column(
                          children: [
                            Text(
                              "Bar",
                              style: TextStyle(
                                  color: isSelectedRole
                                      ? secondaryColor
                                      : Colors.redAccent),
                            ), // Texte au-dessus
                            Radio<String>(
                              value: 'bar',
                              groupValue: selectedRole,
                              fillColor: WidgetStateProperty.all(isSelectedRole
                                  ? secondaryColor
                                  : Colors.redAccent),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedRole = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!isSelectedRole)
                      Text(
                        'Veuillez selectioné un role',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                width: 300,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                            color: isEmailError
                                ? Colors.redAccent
                                : secondaryColor),
                        Text('Votre email',
                            style: TextStyle(
                                color: isEmailError
                                    ? Colors.redAccent
                                    : secondaryColor))
                      ],
                    ),
                    TextField(
                      controller: emailController,
                      cursorColor: secondaryColor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: secondaryColor)),
                        errorText: errorEmailMessage,
                        errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12), // Couleur du texte d'erreur
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide:
                              BorderSide(color: secondaryColor, width: 2),
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
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: 300,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Mot de passe',
                            style: TextStyle(color: secondaryColor))
                      ],
                    ),
                    TextField(
                      controller: passwordController,
                      cursorColor: secondaryColor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: secondaryColor)),
                        errorText: errorPasswordMessage,
                        errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12), // Couleur du texte d'erreur
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide:
                              BorderSide(color: secondaryColor, width: 2),
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
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Le mot de passe doit contenir:',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 10,
                            ),
                          ),
                          Text('- Une majuscule',
                              style: TextStyle(
                                  color: isNotUpper
                                      ? Colors.redAccent
                                      : secondaryColor,
                                  fontSize: 10)),
                          Text('- Une minuscule',
                              style: TextStyle(
                                  color: isNotLower
                                      ? Colors.redAccent
                                      : secondaryColor,
                                  fontSize: 10)),
                          Text('- Un chiffre',
                              style: TextStyle(
                                  color: isNotNumber
                                      ? Colors.redAccent
                                      : secondaryColor,
                                  fontSize: 10)),
                          Text('- Un caractère spécial',
                              style: TextStyle(
                                  color: isNotSpecialChar
                                      ? Colors.redAccent
                                      : secondaryColor,
                                  fontSize: 10)),
                          Text('- Minimun 8 caractères',
                              style: TextStyle(
                                  color: isNotEightMinimal
                                      ? Colors.redAccent
                                      : secondaryColor,
                                  fontSize: 10))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: 300,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: secondaryColor),
                        Text('Confirmer votre mot de passe',
                            style: TextStyle(color: secondaryColor))
                      ],
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      cursorColor: secondaryColor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: secondaryColor)),
                        errorText: errorConfirmPasswordMessage,
                        errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12), // Couleur du texte d'erreur
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide:
                              BorderSide(color: secondaryColor, width: 2),
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
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: primaryColor),
                  onPressed: () => nextPage(),
                  child: Text('Suivant'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
