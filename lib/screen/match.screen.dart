import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/calendar.component.dart';
import '../components/filters.component.dart';
import '../components/matches/match-list.component.dart';

class MatchScreen extends StatefulWidget {
  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  DateTime _selectedDate = DateTime.now(); // La vraie date sélectionnée
  Map<String, List<dynamic>> _filtersList = {};

  @override
  void initState() {
    super.initState();
    // Charger les filtres après l'initialisation du widget
    _loadFilters();
  }

  // Fonction pour charger les filtres de manière asynchrone
  Future<void> _loadFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _filtersList = {
        'games': prefs.getStringList('games') ?? [],
        'leagues': prefs.getStringList('leagues') ?? [],
        'teams': prefs.getStringList('teams') ?? []
      };
    });
  }

  // Callback qui met à jour la date
  void _updateSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _getFiltersList(Map<String, List<String>> filterList) {
    setState(() {
      print(filterList);
      _filtersList = filterList;
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
                    begin: Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ))
                : AlwaysStoppedAnimation(
                    Offset.zero), // Évite une erreur si animation null
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: FilterPage(getSelectedFilters: _getFiltersList),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  // Row pour aligner le calendrier et les icônes horizontalement
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Espacement entre les éléments
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Aligner les icônes verticalement
                        children: [
                          IconButton(
                            icon: Icon(Icons
                                .favorite_border_outlined), // Premier bouton iconique
                            onPressed: () {
                              // Action du premier bouton
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.tune), // Deuxième bouton iconique
                            onPressed: () => _showFilterPage(context),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Expanded(
                          child: HorizontalCalendar(
                              onDateSelected: _updateSelectedDate)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return MatchList(
                  filtersList: _filtersList,
                  selectedDate: _selectedDate, // MatchList scrollable
                );
              },
              childCount:
                  1, // Tu peux mettre le nombre d'éléments dans la liste ici
            ),
          ),
        ],
      ),
    );
  }
}
