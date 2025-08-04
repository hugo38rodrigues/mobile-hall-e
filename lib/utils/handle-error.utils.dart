import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

Future<void> handleError(DioException error, BuildContext context) async {
  final container = ProviderScope.containerOf(context); // <--- 🔥

  Color errorColors = Colors.red;

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    print('Erreur de timeout : ${error.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La requête a pris trop de temps.'),
        backgroundColor: errorColors,
      ),
    );
  } else if (error.response != null) {
    final errorMessage = error.response?.data['message'] ?? 'Erreur inconnue';
    print('Erreur de l\'API : $errorMessage');

    if (error.response?.statusCode == 401) {
      // Token invalide → on déconnecte
      await container.read(accountProvider.notifier).logout();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: errorColors,
      ),
    );
  } else {
    print('Erreur de connexion : ${error.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de connexion'),
        backgroundColor: errorColors,
      ),
    );
  }
}
