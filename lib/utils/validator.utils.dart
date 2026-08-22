// utils/validators.utils.dart
import 'package:hall_e_mobile/utils/constants.utils.dart';

/// Erreur d'un champ : un drapeau + un message optionnel.
typedef FieldError = ({bool hasError, String? message});

const FieldError noFieldError = (hasError: false, message: null);
FieldError fieldError(String message) => (hasError: true, message: message);

/// Champ obligatoire : vérifie seulement qu'il n'est pas vide.
FieldError validateRequired(
  String value, {
  String message = 'Ce champ est vide',
}) {
  return value.isEmpty ? fieldError(message) : noFieldError;
}

/// Email : non vide + format valide.
FieldError validateEmail(
  String value, {
  String emptyMessage = 'Ce champ est vide',
  String invalidMessage = "Ce n'est pas un email",
}) {
  if (value.isEmpty) return fieldError(emptyMessage);
  if (!regexEmail.hasMatch(value)) return fieldError(invalidMessage);
  return noFieldError;
}

/// Résultat détaillé de la robustesse d'un mot de passe.
/// Chaque booléen indique une règle NON respectée (pour piloter la couleur
/// rouge de la checklist), et [isValid] est vrai si toutes les règles passent.
typedef PasswordStrength = ({
  bool notUpper,
  bool notLower,
  bool notNumber,
  bool notSpecial,
  bool notLength,
});

PasswordStrength checkPasswordStrength(String password) {
  return (
    notUpper: !regexUpperCase.hasMatch(password),
    notLower: !regexLowercase.hasMatch(password),
    notNumber: !regexStringWithNumber.hasMatch(password),
    notSpecial: !regexSpecialChar.hasMatch(password),
    notLength: !regexLength8.hasMatch(password),
  );
}

extension PasswordStrengthX on PasswordStrength {
  bool get isValid =>
      !notUpper && !notLower && !notNumber && !notSpecial && !notLength;
}

/// Une règle de mot de passe : son libellé et si elle échoue pour ce `strength`.
typedef PasswordRule = ({String label, bool failing});

List<PasswordRule> passwordRules(PasswordStrength s) => [
      (label: '- Une majuscule', failing: s.notUpper),
      (label: '- Une minuscule', failing: s.notLower),
      (label: '- Un chiffre', failing: s.notNumber),
      (label: '- Un caractère spécial', failing: s.notSpecial),
      (label: '- Minimum 8 caractères', failing: s.notLength),
    ];
