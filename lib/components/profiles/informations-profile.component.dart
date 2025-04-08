import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

class InformationsProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountProvider);
    bool isClient = profile.role == 'client';

    return Center(child: Column(children: []));
  }
}
