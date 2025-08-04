import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class ResetPassword extends StatefulWidget {
  final String? idUser;

  ResetPassword({required this.idUser});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? errorPasswordMessage;
  String? errorConfirmPasswordMessage;
  bool isPasswordError = false;
  bool isConfirmPasswordError = false;
  bool isNotUpper = false;
  bool isNotLower = false;
  bool isNotNumber = false;
  bool isNotSpecialChar = false;
  bool isNotEightMinimal = false;

  bool isLoading = false;

  void _setPasswordError(String message) {
    errorPasswordMessage = message;
    isPasswordError = true;
  }

  void _clearPasswordError() {
    errorPasswordMessage = null;
    isPasswordError = false;
  }

  void _setConfirmPasswordError(String message) {
    errorConfirmPasswordMessage = message;
    isConfirmPasswordError = true;
  }

  void _clearConfirmPasswordError() {
    errorConfirmPasswordMessage = null;
    isConfirmPasswordError = false;
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
      _clearConfirmPasswordError();
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
        _setPasswordError('Ce champ est vide');
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

  Future sendResetPassword(String newPassword) async {
    isLoading = true;

    String? apiUrl = dotenv.env['API_URL'];

    try {
      setState(() {
        isLoading = true;
      });

      Response response = await request(
          {'id': widget.idUser, 'password': newPassword},
          '$apiUrl/reset-password',
          'post');

      if (response.statusCode == 200) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          Navigator.pop(context, "Mot de passe réinitialisé avec succès !");
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          Navigator.pop(context);
          isLoading = false;
        });
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  onSubmit() {
    setState(() {
      _clearPasswordError();
      _clearConfirmPasswordError();
    });

    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    bool isValidNewPassword = validatePasswords(newPassword);
    bool isValidConfirmNewPassword = isValidConfirmPassword(confirmPassword);

    if (newPassword != confirmPassword) {
      setState(() {
        _setPasswordError('Les mots de passe ne correspondent pas');
        _setConfirmPasswordError('Les mots de passe ne correspondent pas');
      });
      return;
    }

    if (isValidConfirmNewPassword && isValidNewPassword) {
      sendResetPassword(newPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 280,
            height: 210,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.person,
                        color: isPasswordError
                            ? Colors.redAccent
                            : secondaryColor),
                    Text('Nouveau mot de passe ',
                        style: TextStyle(
                            color: isPasswordError
                                ? Colors.redAccent
                                : secondaryColor)),
                  ],
                ),
                TextField(
                  controller: newPasswordController,
                  cursorColor: secondaryColor,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: secondaryColor)),
                    errorText: errorPasswordMessage,
                    errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12), // Couleur du texte d'erreur
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: secondaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                          color: Colors.redAccent,
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
                ),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            height: 120,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.person,
                        color: isConfirmPasswordError
                            ? Colors.redAccent
                            : secondaryColor),
                    Text('Confirmer le mot de passe',
                        style: TextStyle(
                            color: isConfirmPasswordError
                                ? Colors.redAccent
                                : secondaryColor)),
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
                        color: Colors.redAccent,
                        fontSize: 12), // Couleur du texte d'erreur
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: secondaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                          color: Colors.redAccent,
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
          SizedBox(
              width: 250,
              child: isLoading
                  ? CustomLoader(text: "Changement de mot de passe")
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor),
                      onPressed: onSubmit,
                      child: Text(
                        'Changer votre mot de passe',
                        style: TextStyle(color: primaryColor),
                      ),
                    ))
        ],
      ),
    );
  }
}
