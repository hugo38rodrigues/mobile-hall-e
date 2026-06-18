import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';

Future<void> handleError(DioException error, BuildContext context) async {
  final String message = _resolveMessage(error);

  if (error.response?.statusCode == 401) {
    final container = ProviderScope.containerOf(context);
    await container.read(accountProvider.notifier).logout();
  }

  if (!context.mounted) return;

  showErrorSnackBar(context, message);
}

String _resolveMessage(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'La requête a pris trop de temps.';
  }

  if (error.response != null) {
    final data = error.response?.data;
    return data is Map
        ? (data['message'] ?? 'Erreur inconnue')
        : (data?.toString() ?? 'Erreur inconnue');
  }

  return 'Erreur de connexion';
}
