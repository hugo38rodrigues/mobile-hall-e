import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'styles/font-colors.dart';
import 'screen/home.screen.dart';
import 'screen/sign-in.screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Assurez-vous que Flutter est bien initialisé
  await initializeDateFormatting('fr_FR', null);
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EZONE',
      theme: ThemeData(
        fontFamily: 'Lexend',
        textTheme: textThemes,
      ),
      home: HomeScreen(), // Vérifie l'authentification au démarrage,
    );
  }
}
