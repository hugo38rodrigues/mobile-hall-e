import 'package:flutter/material.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchEmail(BuildContext context) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: emailHallE,
    queryParameters: {
      'subject': subject,
    },
  );
  
  // WARNING: Probleme d'ouverture de l'application mail

  final canLaunch = await canLaunchUrl(emailUri);
  if (!context.mounted) return;

  if (canLaunch) {
    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  } else {
    showErrorSnackBar(context, "Impossible d’ouvrir l’application de messagerie");
  }
}
