import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'styles/font-colors.dart';
import 'screen/home.screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajoutez cette importation

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Assurez-vous que Flutter est bien initialisé
  await initializeDateFormatting('fr_FR', null);
  await dotenv.load(fileName: ".env");
  final container = ProviderContainer();
  await container.read(accountProvider.notifier).loadAccount();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Ajoutez l'observateur du cycle de vie
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Si l'application passe en arrière-plan ou se ferme
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _clearUserData();
    }
  }

  void _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user'); // Effacer les données de l'utilisateur
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ezone',
      theme: ThemeData(
        fontFamily: 'Lexend',
        textTheme: textThemes,
      ),
      home: HomeScreen(), // Vérifie l'authentification au démarrage
    );
  }
}
