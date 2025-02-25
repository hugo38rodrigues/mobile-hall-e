import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// Fonction de gestion des erreurs avec Dio v5
Future<void> handleError(DioException error, BuildContext context) async {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    // Gère le timeout
    print('Erreur de timeout : ${error.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('La requête a pris trop de temps.')),
    );
  } else if (error.response != null) {
    // Si l'erreur provient de la réponse de l'API
    String errorMessage = error.response?.data['message'] ?? 'Erreur inconnue';
    print('Erreur de l\'API : $errorMessage');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } else {
    // Gère le cas où la réponse de l'API n'a pas été reçue (problème de connexion)
    print('Erreur de connexion : ${error.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur de connexion')),
    );
  }
}
