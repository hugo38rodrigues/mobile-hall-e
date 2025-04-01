import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/bars-screen/bar-list.component.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class BarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
