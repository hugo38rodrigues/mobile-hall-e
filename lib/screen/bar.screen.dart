import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/bars-screen/bar-list.component.dart';
import 'package:hall_e_mobile/components/bars-screen/programation-match-list.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class BarScreen extends ConsumerStatefulWidget {
  @override
  _BarScreenState createState() => _BarScreenState();
}

class _BarScreenState extends ConsumerState<BarScreen> {
  @override
  Widget build(BuildContext context) {
    String role = ref.watch(accountProvider).role;

    return Scaffold(
        backgroundColor: primaryColor,
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (role == 'bar') {
                    return ProgramationMatchList();
                  }
                  return BarList();
                },
                childCount:
                    1, // Tu peux mettre le nombre d'éléments dans la liste ici
              ),
            ),
          ],
        ));
  }
}
