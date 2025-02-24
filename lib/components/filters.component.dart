import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../styles/font-colors.dart';

class FilterPage extends StatefulWidget {
  final Function(Map<String, List<String>>) getSelectedFilters;
  FilterPage({required this.getSelectedFilters});
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String boutonSelectionne = 'games';
  Map<String, List<String>> arrayFiltersSelected = {
    'games': [],
    'leagues': [],
    'teams': []
  };

  List gameNames = []; // Liste vide, remplie via l'API
  List leagueNames = []; // Liste vide, remplie via l'API
  List teams = []; // Liste vide, remplie via l'API
  bool isLoading = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _getFilters();
    _filtersSelectionLoad();
  }

  Future<void> _getFilters() async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    try {
      Response response = await dio.get('$apiUrl/commun/filters');
      setState(() {
        gameNames = response.data['filters']['gameNames'] ?? [];
        leagueNames = response.data['filters']['leagueNames'] ?? [];
        teams = response.data['filters']['teamNames'] ?? [];
        isLoading = false;
      });
    } catch (error) {
      print('Erreur: $error');
      setState(() {
        isLoading = false; // Si erreur, on arrête le chargement
      });
    }
  }

  Future<void> _filtersSelectionLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      arrayFiltersSelected = {
        'games': prefs.getStringList('games') ?? [],
        'leagues': prefs.getStringList('leagues') ?? [],
        'teams': prefs.getStringList('teams') ?? []
      };
    });
  }

  Future<void> _filtersSelectionSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('games', arrayFiltersSelected['games'] ?? []);
    await prefs.setStringList('leagues', arrayFiltersSelected['leagues'] ?? []);
    await prefs.setStringList('teams', arrayFiltersSelected['teams'] ?? []);
  }

  void _filtersManageSelect(String item) {
    setState(() {
      arrayFiltersSelected.putIfAbsent(boutonSelectionne, () => []);
      List<String> selection = arrayFiltersSelected[boutonSelectionne]!;

      if (selection.contains(item)) {
        selection.remove(item);
      } else {
        selection.add(item);
      }
      _filtersSelectionSave();
    });
  }

  bool _isSelectedFilterBtn() {
    return arrayFiltersSelected.values.any((list) => list.isNotEmpty);
  }

  List<dynamic> _filtersManage() {
    List<dynamic> selectedItems = [];

    // Récupérer les éléments en fonction de la catégorie sélectionnée

    // Appliquer les filtres de recherche
    if (searchQuery.isNotEmpty) {
      List<Map<String, dynamic>> allItems = [];

      // Ajouter les éléments des trois catégories (gameNames, leagueNames, teams)
      allItems
          .addAll(gameNames.map((item) => {'category': 'games', 'item': item}));
      allItems.addAll(
          leagueNames.map((item) => {'category': 'leagues', 'item': item}));
      allItems.addAll(teams.map((item) => {'category': 'teams', 'item': item}));

      // Appliquer les filtres de recherche sur toutes les catégories combinées

      selectedItems = allItems
          .where((element) => element['item']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .map((e) => e['item']) // Récupérer seulement l'élément 'item' du Map
          .toList();
    } else {
      switch (boutonSelectionne) {
        case 'games':
          selectedItems = gameNames;
          break;
        case 'leagues':
          selectedItems = leagueNames;
          break;
        case 'teams':
          selectedItems = teams;
          break;
        default:
          selectedItems = [];
          break;
      }
    }

    return selectedItems;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> selectedFilters = _filtersManage();

    List<dynamic> selectedItems = selectedFilters
        .where((item) =>
            arrayFiltersSelected[boutonSelectionne]?.contains(item) ?? false)
        .toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));

    List<dynamic> unselectedItems = selectedFilters
        .where((item) =>
            !(arrayFiltersSelected[boutonSelectionne]?.contains(item) ?? false))
        .toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));

    List<dynamic> orderedFilters = [...selectedItems, ...unselectedItems];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrer vos matchs',
                style: TextStyle(
                  fontSize: 20,
                  color: secondaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: secondaryColor,
                onPressed: () {
                  widget.getSelectedFilters(arrayFiltersSelected);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            cursorColor: secondaryColor,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: secondaryColor),
              hintText: 'Rechercher...',
              hintStyle: TextStyle(color: secondaryColor),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: boutonSelectionne == 'games'
                              ? secondaryColor
                              : primaryColor,
                          foregroundColor: boutonSelectionne == 'games'
                              ? primaryColor
                              : secondaryColor,
                          side: BorderSide(
                            color: secondaryColor,
                            width: 1.0,
                          )),
                      onPressed: () {
                        setState(() {
                          boutonSelectionne = 'games';
                        });
                      },
                      child: const Text('Jeux'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: boutonSelectionne == 'leagues'
                              ? secondaryColor
                              : primaryColor,
                          foregroundColor: boutonSelectionne == 'leagues'
                              ? primaryColor
                              : secondaryColor,
                          side: BorderSide(
                            color: secondaryColor,
                            width: 1.0,
                          )),
                      onPressed: () {
                        setState(() {
                          boutonSelectionne = 'leagues';
                        });
                      },
                      child: const Text('Compétitions'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: boutonSelectionne == 'teams'
                              ? secondaryColor
                              : primaryColor,
                          foregroundColor: boutonSelectionne == 'teams'
                              ? primaryColor
                              : secondaryColor,
                          side: BorderSide(
                            color: secondaryColor,
                            width: 1.0,
                          )),
                      onPressed: () {
                        setState(() {
                          boutonSelectionne = 'teams';
                        });
                      },
                      child: const Text('Équipes'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: orderedFilters
                      .map((item) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  arrayFiltersSelected[boutonSelectionne]
                                              ?.contains(item) ??
                                          false
                                      ? secondaryColor
                                      : primaryColor,
                              foregroundColor:
                                  arrayFiltersSelected[boutonSelectionne]
                                              ?.contains(item) ??
                                          false
                                      ? primaryColor
                                      : secondaryColor,
                            ),
                            onPressed: () => _filtersManageSelect(item),
                            child: Text(item),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // Le bouton de réinitialisation en bas
        Padding(
            padding: const EdgeInsets.only(bottom: 50), // Remonte de 20 pixels
            child: ElevatedButton(
              onPressed: _isSelectedFilterBtn()
                  ? () {
                      setState(() {
                        arrayFiltersSelected.forEach((key, value) {
                          arrayFiltersSelected[key] = [];
                        });
                        _filtersSelectionSave();
                      });
                    }
                  : null, // Si null, le bouton est désactivé
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSelectedFilterBtn()
                    ? secondaryColor
                    : primaryColor, // Rouge si cliquable, gris sinon
                foregroundColor: primaryColor,
              ),

              child: Text(
                'Réinitialiser les filtres',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            )),
      ],
    );
  }
}
