import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/identification/identification-wrapper.logins.dart';
import 'package:hall_e_mobile/components/profiles/profile.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountProvider);
    String role = profile.role;
    // Lire la valeur
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [role == 'guest' ? IdendtificationWrapper() : Profile()],
        ),
      ),
    );
  }
}
