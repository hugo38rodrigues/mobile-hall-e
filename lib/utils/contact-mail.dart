import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: emailHallE,
    queryParameters: {
      'subject': subject,
    },
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Impossible d’ouvrir l’application de messagerie';
  }
}
