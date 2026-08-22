// components/labeled_text_field.component.dart
import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hasError = false,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onToggleObscure,
    this.suffixIcon,
    this.errorFontSize = 14,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool hasError;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onToggleObscure;
  final Widget? suffixIcon;
  final double errorFontSize;

  @override
  Widget build(BuildContext context) {
    final color = hasError ? Colors.red : textGold;

    // Le toggle mot de passe prime sur un suffixIcon custom éventuel.
    final resolvedSuffix = onToggleObscure != null
        ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: textGold,
            ),
            onPressed: onToggleObscure,
          )
        : suffixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          style: const TextStyle(color: textWhite),
          controller: controller,
          cursorColor: textGold,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: _decoration(resolvedSuffix),
        ),
      ],
    );
  }

  InputDecoration _decoration(Widget? suffixIcon) {
    const radius = BorderRadius.all(Radius.circular(20));
    return InputDecoration(
      errorText: errorText,
      suffixIcon: suffixIcon,
      errorStyle: TextStyle(color: Colors.red, fontSize: errorFontSize),
      border: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: textGold),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: textGold, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
