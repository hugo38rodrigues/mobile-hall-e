import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/bars/bar-list.component.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class BarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: 130,
                  height: 40,
                  child: ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor),
                      child: Text(
                        'Map',
                        style: TextStyle(color: primaryColor, fontSize: 18),
                      )),
                ),
              ],
            ),
          ),
        ),
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
