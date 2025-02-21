import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/connexion.component.dart';
import 'package:hall_e_mobile/components/profiles.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountProvider);
    String role = profile['role'];
    // Lire la valeur
    return Column(
      children: [role == 'invité' ? Connexion() : Profiles()],
    );
  }
}
