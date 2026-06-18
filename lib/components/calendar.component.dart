import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:intl/intl.dart';



class HorizontalCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  HorizontalCalendar({required this.onDateSelected});

  @override
  _HorizontalCalendarState createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  DateTime _selectedDate = DateTime.now(); // Gère la sélection

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates =
        List.generate(14, (index) => DateTime.now().add(Duration(days: index)));

    return SizedBox(
      height: 40,
      width: 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          DateTime date = dates[index];
          String displayText = index == 0
              ? "Aujourd'hui"
              : index == 1
                  ? "Demain"
                  : DateFormat('dd.MMM', 'fr_FR').format(date);

          // Vérifier si la date sélectionnée correspond
          bool isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date; // Mise à jour locale
                });

                widget.onDateSelected(date); // Envoi de la vraie date au parent
              },
              child: Container(
                width: 95,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? textGold : background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color:isSelected ? textGold: textGrey),
                ),
                child: Center(
                  child: Text(
                    displayText, // 🔥 Affiche bien "Aujourd'hui" mais envoie la vraie date
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? background : textGrey,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
