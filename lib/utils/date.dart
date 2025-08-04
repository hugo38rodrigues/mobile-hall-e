import 'package:intl/intl.dart';

String formatDate(String date) {
  // Forcer le parsing en UTC
  DateTime dateTime = DateTime.parse(date).toLocal();

  // Formatter l'heure sans conversion locale
  String formattedTime = DateFormat("dd'/'MM 'à' HH'h'mm").format(dateTime);
  return formattedTime;
}
