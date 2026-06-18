import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/bars-screen/bar-list.component.dart';
import 'package:hall_e_mobile/components/bars-screen/programation-match-list.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

class BarScreen extends ConsumerStatefulWidget {
  @override
  _BarScreenState createState() => _BarScreenState();
}

class _BarScreenState extends ConsumerState<BarScreen> {
  @override
  Widget build(BuildContext context) {
    bool isBar = ref.watch(accountProvider).role == 'bar';

    return isBar ? MyProgramationMatchList() : BarList();
  }
}
