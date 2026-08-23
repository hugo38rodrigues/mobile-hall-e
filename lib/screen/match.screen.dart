import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import '../use-case/calendar.component.dart';
import '../use-case/filters.component.dart';
import '../use-case/matches/match_list.component.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<dynamic>> _filtersList = {};
  bool _isFavoritesSelected = false;

  // Aucune persistance : les filtres démarrent vides à chaque ouverture
  // et ne sont pas rechargés depuis SharedPreferences.

  /// Nombre total de filtres actifs, toutes catégories confondues.
  int get _activeFiltersCount =>
      _filtersList.values.fold(0, (total, list) => total + list.length);

  /// Met à jour la date sélectionnée dans le calendrier.
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  /// Reçoit la nouvelle sélection de filtres renvoyée par la FilterPage.
  void _onFiltersChanged(Map<String, List<String>> filters) {
    setState(() {
      _filtersList = filters;
    });
  }

  /// Ouvre la page de filtres dans une bottom sheet animée.
  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: background,
      builder: (context) {
        final animation = ModalRoute.of(context)?.animation;
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: SlideTransition(
            position: animation != null
                ? Tween<Offset>(
                        begin: const Offset(-1.0, 0.0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeInOut))
                : const AlwaysStoppedAnimation(Offset.zero),
            child: Material(
              color: background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: FilterPage(
                getSelectedFilters: _onFiltersChanged,
                // Restaure la sélection courante dans la page de filtres.
                initialFilters: _filtersList.map(
                  (key, value) => MapEntry(key, value.cast<String>()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: background,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Badge(
                          // Masque la bulle quand il n'y a aucun filtre actif.
                          isLabelVisible: _activeFiltersCount > 0,
                          backgroundColor: textGold,
                          textColor: background,
                          label: Text('$_activeFiltersCount'),
                          child: IconButton(
                            icon: const Icon(Icons.tune),
                            color: textWhite,
                            onPressed: () => _openFilterSheet(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: HorizontalCalendar(
                            onDateSelected: _onDateSelected,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: MatchList(
                      isFavoritesSelected: _isFavoritesSelected,
                      filtersList: _filtersList,
                      selectedDate: _selectedDate,
                    ),
                  );
                },
                childCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
