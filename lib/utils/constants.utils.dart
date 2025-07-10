import 'package:flutter_dotenv/flutter_dotenv.dart';

const String loadMatchText = "Chargement des matchs...";
const String connexionText = "Vous avez déjà un compte ? Se connecter";
String? apiUrl = dotenv.env['API_URL'];

RegExp regexEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
RegExp regexLength8 = RegExp(r"^.{8,}$");
RegExp regexUpperCase = RegExp(r"(?=.*[A-Z])");
RegExp regexStringWithNumber = RegExp(r".*\d.*$");
RegExp regexSpecialChar = RegExp(r'.*[!@#$%^&*(),.?\":{}|<>].*$');
RegExp regexLowercase = RegExp(r"(?=.*[a-z])");
RegExp regexStreet = RegExp(r"^\d+\s(?:[a-zA-ZÀ-ÿ]+\.?\s?)+$");
RegExp regexCity = RegExp(r"^[a-zA-ZÀ-ÿ'’ -]+$");
RegExp regexNumberOfStreet = RegExp(r'^\d{5}$');
RegExp regexTwitch = RegExp(r'(twitch)');


