import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/calendar.component.dart';
import '../components/filters.component.dart';
import '../components/matches/match-list.component.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<dynamic>> _filtersList = {};
  bool _isFavoritesSelected = false;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _filtersList = {
        'games': prefs.getStringList('games') ?? [],
        'leagues': prefs.getStringList('leagues') ?? [],
        'teams': prefs.getStringList('teams') ?? [],
      };
    });
  }

  void _updateSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _getFiltersList(Map<String, List<String>> filterList) {
    setState(() {
      _filtersList = filterList;
    });
  }

  void _getIsFavorisSelected(bool isFavoritesSelected) {
    setState(() {
      _isFavoritesSelected = isFavoritesSelected;
    });
  }

  void _showFilterPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: FilterPage(
                getSelectedFilters: _getFiltersList,
                getIsFavorisSelected: _getIsFavorisSelected,
                isFavoritesSelected: _isFavoritesSelected,
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
        color: primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune),
                          color: secondaryColor,
                          onPressed: () => _showFilterPage(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: HorizontalCalendar(
                            onDateSelected: _updateSelectedDate,
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
