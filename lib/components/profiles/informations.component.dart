import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class InformationsComponent extends ConsumerStatefulWidget {
  final User profile;
  InformationsComponent({super.key, required this.profile});

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<InformationsComponent> {
  late TextEditingController emailController;
  late TextEditingController roleController;
  late TextEditingController passwordController;

  late String errorMessage;
  bool isErrorPassword = false;
  bool isErrorEmail = false;
  bool isErrorLastName = false;
  bool isErrorFirstName = false;
  bool isErrorAddress = false;
  bool isErrorBarName = false;

  TextEditingController? firstNameController;
  TextEditingController? lastNameController;

  TextEditingController? barNameController;
  TextEditingController? barAddressController;
  TextEditingController? barDescriptionController;

  bool _isLoading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController(text: widget.profile.email);
    roleController = TextEditingController(text: widget.profile.role);
    passwordController = TextEditingController();

    if (widget.profile.role == 'client') {
      firstNameController =
          TextEditingController(text: widget.profile.informations.firstName);
      lastNameController =
          TextEditingController(text: widget.profile.informations.lastName);
    } else {
      barNameController =
          TextEditingController(text: widget.profile.informations.name);
      barAddressController =
          TextEditingController(text: widget.profile.informations.address);
      barDescriptionController =
          TextEditingController(text: widget.profile.informations.description);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    roleController.dispose();
    passwordController.dispose();

    firstNameController?.dispose();
    lastNameController?.dispose();
    barNameController?.dispose();
    barAddressController?.dispose();
    barDescriptionController?.dispose();

    super.dispose();
  }

  Future<void> sendUpdateProfile(
      WidgetRef ref, Map<String, dynamic> profile) async {
    setState(() {
      _isLoading = false;
    });

    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .put('$apiUrl/',
              data: {'userId': widget.profile.id, 'profile': profile},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer ${widget.profile.token}"
                },
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          _isLoading = false;
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        ref.read(accountProvider.notifier).updateAccount(
            {'email': data.email, 'information': data.informations});
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  bool checkEmail(String email) {
    return regexEmail.hasMatch(email);
  }

  bool passwordHasEightMinimal(String password) {
    return regexLength8.hasMatch(password);
  }

  bool passwordHasSpecialChar(String password) {
    return regexSpecialChar.hasMatch(password);
  }

  bool passwordHasNumber(String password) {
    return regexStringWithNumber.hasMatch(password);
  }

  bool passwordHasUpper(String password) {
    return regexUpperCase.hasMatch(password);
  }

  bool checkName(String name) {
    return regexString.hasMatch(name);
  }

  bool checkFormatAddress(String address) {
    return address.split(',').length > 1;
  }

  bool checkStreet(String street) {
    return regexStreet.hasMatch(street);
  }

  bool checkPostalCode(String postalCode) {
    return regexPostalCode.hasMatch(postalCode);
  }

  bool checkCity(String city) {
    return regexCity.hasMatch(city);
  }

  bool validateClientInputs(String firstName, String lastName) {
    bool isValid = true;

    if (!checkName(firstName)) {
      isErrorFirstName = true;
      errorMessage = "Votre prénom doit contenir uniquement des lettres";
      isValid = false;
    }

    if (!checkName(lastName)) {
      isErrorLastName = true;
      errorMessage = "Votre nom doit contenir uniquement des lettres";
      isValid = false;
    }

    return isValid;
  }

  bool validateBarInputs(String name, String address) {
    bool isValid = true;

    if (!checkName(name)) {
      isErrorBarName = true;
      errorMessage = "Le nom du bar doit contenir uniquement des lettres";
      isValid = false;
    }

    if (!checkFormatAddress(address)) {
      isErrorAddress = true;
      errorMessage =
          "Adresse invalide. Format attendu: rue, code postal, ville";
      return false;
    }

    final parts = address.split(',');
    if (parts.length < 3) {
      isErrorAddress = true;
      errorMessage = "Adresse incomplète";
      return false;
    }

    if (!checkStreet(parts[0])) {
      isErrorAddress = true;
      errorMessage = "Rue invalide : commencez par un numéro puis une rue";
      isValid = false;
    }

    if (!checkPostalCode(parts[1].trim())) {
      isErrorAddress = true;
      errorMessage = "Code postal invalide";
      isValid = false;
    }

    if (!checkCity(parts[2].trim())) {
      isErrorAddress = true;
      errorMessage = "Ville invalide";
      isValid = false;
    }

    return isValid;
  }

  bool validatePassword(String password) {
    if (!passwordHasEightMinimal(password)) {
      errorMessage = "Mot de passe : minimum 8 caractères";
      return false;
    }

    if (!passwordHasNumber(password)) {
      errorMessage = "Mot de passe : doit contenir un chiffre";
      return false;
    }

    if (!passwordHasSpecialChar(password)) {
      errorMessage = "Mot de passe : doit contenir un caractère spécial";
      return false;
    }

    if (!passwordHasUpper(password)) {
      errorMessage = "Mot de passe : doit contenir une majuscule";
      return false;
    }

    return true;
  }

  void submitData(WidgetRef ref) {
    final email = emailController.text;
    final password = passwordController.text;
    final role = roleController.text;

    late String firstName;
    late String lastName;
    late String description;
    late String barName;
    late String address;

    bool isValid = true;
    isErrorFirstName = isErrorLastName = isErrorBarName =
        isErrorAddress = isErrorPassword = isErrorEmail = false;

    if (!checkEmail(email)) {
      isErrorEmail = true;
      errorMessage = "Email invalide";
      isValid = false;
    }

    if (password != '' && !validatePassword(password)) {
      isErrorPassword = true;
      isValid = false;
    }

    if (role == 'client') {
      firstName = firstNameController!.text;
      lastName = lastNameController!.text;
      isValid &= validateClientInputs(firstName, lastName);
    } else {
      barName = barNameController?.text ?? '';
      address = barAddressController?.text ?? '';
      description = barDescriptionController?.text ?? '';
      isValid &= validateBarInputs(barName, address);
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    final profile = role == 'client'
        ? {
            "firstName": firstName,
            "lastName": lastName,
          }
        : {
            "name": barName,
            "address": address,
            "description": description,
          };

    final completeProfile = {
      'email': email,
      'password': password,
      'role': role,
      ...profile,
    };
    setState(() {
      passwordController.text = "";
    });

    sendUpdateProfile(ref, completeProfile);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    bool hasError = isErrorPassword ||
        isErrorEmail ||
        isErrorLastName ||
        isErrorFirstName ||
        isErrorAddress ||
        isErrorBarName;
    Color colorsFirstName = isErrorFirstName ? Colors.red : secondaryColor;
    Color colorsLastName = isErrorLastName ? Colors.red : secondaryColor;
    Color colorsEmail = isErrorEmail ? Colors.red : secondaryColor;
    Color colorsPassword = isErrorPassword ? Colors.red : secondaryColor;
    Color colorsBarName = isErrorBarName ? Colors.red : secondaryColor;
    Color colorsAddress = isErrorAddress ? Colors.red : secondaryColor;
    Color colorsErrorMessage = hasError ? Colors.red : secondaryColor;

    return Card(
      color: primaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: secondaryColor)),
      borderOnForeground: true,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Text(
                'Vos informations',
                style: TextStyle(color: secondaryColor, fontSize: 20),
              )
            ]),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: emailController,
              cursorColor: colorsEmail,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: colorsEmail)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: secondaryColor, width: 2),
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: colorsEmail)),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              cursorColor: colorsPassword,
              obscureText:
                  obscurePassword, // ✅ obligatoire pour cacher le texte
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: colorsPassword)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: colorsPassword, width: 2),
                ),
                labelText: 'Changer votre mot de passe',
                labelStyle: TextStyle(color: secondaryColor),

                // ✅ ton suffixIcon ici, pas ailleurs
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: secondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: roleController,
              readOnly: true,
              cursorColor: secondaryColor,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: secondaryColor)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: secondaryColor, width: 2),
                ),
                labelText: 'Role',
                labelStyle: TextStyle(color: secondaryColor),
              ),
            ),
            SizedBox(height: 15),
            if (profile.role == 'client')
              Column(
                children: [
                  TextFormField(
                    controller: firstNameController,
                    cursorColor: colorsFirstName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: colorsFirstName)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide:
                            BorderSide(color: colorsFirstName, width: 2),
                      ),
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: colorsFirstName),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: lastNameController,
                    cursorColor: colorsLastName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: secondaryColor)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: colorsLastName, width: 2),
                      ),
                      labelText: 'Prénom',
                      labelStyle: TextStyle(color: colorsLastName),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  TextFormField(
                    controller: barNameController,
                    cursorColor: colorsBarName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: colorsBarName)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: colorsBarName, width: 2),
                      ),
                      labelText: 'Nom du bar',
                      labelStyle: TextStyle(color: colorsBarName),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: barAddressController,
                    cursorColor: colorsAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: colorsAddress)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: colorsAddress, width: 2),
                      ),
                      labelText: 'Adresse',
                      labelStyle: TextStyle(color: colorsAddress),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: barDescriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: secondaryColor)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: secondaryColor, width: 2),
                      ),
                      labelText: 'Description',
                      labelStyle: TextStyle(color: secondaryColor),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10),
            hasError
                ? Text(errorMessage,
                    style: TextStyle(color: colorsErrorMessage))
                : SizedBox.shrink(),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: secondaryColor, // couleur de la bordure
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => submitData(ref),
              child: _isLoading
                  ? CustomLoader(text: 'Enregistrement en cours...')
                  : Text(
                      'Enregistrer les modifications',
                      style: TextStyle(color: secondaryColor),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
