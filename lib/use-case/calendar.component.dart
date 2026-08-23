import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:intl/intl.dart';

class HorizontalCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const HorizontalCalendar({super.key, required this.onDateSelected});

  @override
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  DateTime _selectedDate = DateTime.now();

  // Les 14 prochains jours, calculés une seule fois.
  late final List<DateTime> _dates =
      List.generate(14, (index) => DateTime.now().add(Duration(days: index)));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _labelFor(int index, DateTime date) {
    if (index == 0) return "Aujourd'hui";
    if (index == 1) return "Demain";
    return DateFormat('dd.MMM', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Hauteur alignée sur celle des cases (60) : plus de débordement,
      // et plus de width:10 qui écrasait la liste.
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = _isSameDay(_selectedDate, date);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.0),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
                widget.onDateSelected(date);
              },
              child: Container(
                width: 95,
                decoration: BoxDecoration(
                  color: isSelected ? textGold : background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? textGold : textGrey),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labelFor(index, date),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? background : textGrey,
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
