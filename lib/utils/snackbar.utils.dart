import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

enum SnackBarType { success, error, info, warning }

void showAppSnackBar(BuildContext context, String message,
    {SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    bool hasCirculair = false}) {
  final config = _snackBarConfig(type);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            hasCirculair
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  )
                : Icon(config.icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );
}

// ---------------------------------------------------------------------------
// Methodes globals
// ---------------------------------------------------------------------------
void showSuccessSnackBar(BuildContext context, String message) =>
    showAppSnackBar(context, message, type: SnackBarType.success);

void showErrorSnackBar(BuildContext context, String message) =>
    showAppSnackBar(context, message, type: SnackBarType.error);

void showInfoSnackBar(BuildContext context, String message) =>
    showAppSnackBar(context, message, type: SnackBarType.info);

void showWarningSnackBar(BuildContext context, String message) =>
    showAppSnackBar(context, message, type: SnackBarType.warning);

void showInfoWithCirculairSnackBar(BuildContext context, String message) =>
    showAppSnackBar(context, message,
        type: SnackBarType.info, hasCirculair: true);

// ---------------------------------------------------------------------------
// Config interne
// ---------------------------------------------------------------------------
typedef _SnackBarConfig = ({Color color, IconData icon});

_SnackBarConfig _snackBarConfig(SnackBarType type) {
  return switch (type) {
    SnackBarType.success => (
        color: Colors.green.shade600,
        icon: Icons.check_circle_outline,
      ),
    SnackBarType.error => (
        color: Colors.red.shade600,
        icon: Icons.error_outline,
      ),
    SnackBarType.warning => (
        color: Colors.orange.shade700,
        icon: Icons.warning_amber_outlined,
      ),
    SnackBarType.info => (
        color: textGold,
        icon: Icons.info_outline,
      ),
  };
}
