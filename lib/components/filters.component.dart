import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../styles/font-colors.dart';

class FilterPage extends ConsumerStatefulWidget {
  final Function(Map<String, List<String>>) getSelectedFilters;
  final Function(bool) getIsFavorisSelected;
  final bool isFavoritesSelected;

  const FilterPage(
      {required this.getSelectedFilters,
      required this.getIsFavorisSelected,
      required this.isFavoritesSelected,
      super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  String? userRole;
  String selectedButton = 'games';
  bool _resetBtnFilter = false;

  Map<String, List<String>> arrayFiltersSelected = {
    'games': [],
    'leagues': [],
    'teams': [],
    'barName': []
  };

  List<String> gameNames = [];
  List<String> leagueNames = [];
  List<String> teams = [];
  List<String> barNames = [];

  bool isLoading = true;
  String searchQuery = "";

  final Map<String, String> categoryTranslations = {
    'games': 'Jeux',
    'leagues': 'Compétitions',
    'teams': 'Équipes',
    'barName': 'Nom des bars',
    'favoris': 'Vos favoris'
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userRole == null) {
      final user = ref.read(accountProvider);
      userRole = user.role;
      _getFilters();
      _filtersSelectionLoad();
    }
  }

  Future<void> _getFilters() async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    try {
      Response response = await dio.get('$apiUrl/filters').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/filters'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          gameNames =
              List<String>.from(response.data['filters']['gameNames'] ?? []);
          leagueNames =
              List<String>.from(response.data['filters']['leagueNames'] ?? []);
          teams =
              List<String>.from(response.data['filters']['teamNames'] ?? []);
          if (userRole == 'client') {
            barNames =
                List<String>.from(response.data['filters']['barName'] ?? []);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);

        if (!mounted) return; // Vérifie encore après un await
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _filtersSelectionLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      arrayFiltersSelected = {
        'games': prefs.getStringList('games') ?? [],
        'leagues': prefs.getStringList('leagues') ?? [],
        'teams': prefs.getStringList('teams') ?? [],
        'barName': prefs.getStringList('barName') ?? [],
      };
    });
  }

  Future<void> _filtersSelectionSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('games', arrayFiltersSelected['games'] ?? []);
    await prefs.setStringList('leagues', arrayFiltersSelected['leagues'] ?? []);
    await prefs.setStringList('teams', arrayFiltersSelected['teams'] ?? []);
  }

  void _filtersManageSelect(String category, String item) {
    setState(() {
      List<String> selection = arrayFiltersSelected[category]!;
      if (selection.contains(item)) {
        selection.remove(item);
      } else {
        selection.add(item);
      }
      _filtersSelectionSave();
    });
  }

  List<Map<String, String>> _filtersManage() {
    List<Map<String, String>> allItems = [
      ...gameNames.map((item) => {'category': 'games', 'item': item}),
      ...leagueNames.map((item) => {'category': 'leagues', 'item': item}),
      ...teams.map((item) => {'category': 'teams', 'item': item}),
    ];

    if (userRole == 'client') {
      allItems.addAll(
        barNames.map((item) => {'category': 'barName', 'item': item}),
      );
    }

    List<Map<String, String>> filteredItems;

    if (searchQuery.isNotEmpty) {
      filteredItems = allItems
          .where((e) =>
              e['item']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    } else {
      filteredItems =
          allItems.where((e) => e['category'] == selectedButton).toList();
    }

    List<Map<String, String>> selectedItems = filteredItems
        .where((e) =>
            arrayFiltersSelected[e['category']]?.contains(e['item']) ?? false)
        .toList();

    List<Map<String, String>> unselectedItems = filteredItems
        .where((e) =>
            !(arrayFiltersSelected[e['category']]?.contains(e['item']) ??
                false))
        .toList();

    return [...selectedItems, ...unselectedItems];
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = ['games', 'leagues', 'teams'];
    if (userRole == 'client') {
      categories.add('barName');
    }
    if (userRole == "client" || userRole == "bar") {
      categories.add('favoris');
    }
    bool isArrayFilterNotEmpty =
        arrayFiltersSelected.values.any((list) => list.isNotEmpty);

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filtrer vos matchs',
                        style: TextStyle(
                            fontSize: 20,
                            color: secondaryColor,
                            fontWeight: FontWeight.w800)),
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
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: secondaryColor),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor))),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Column(
                        children: categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedButton == category
                                    ? secondaryColor
                                    : primaryColor,
                                foregroundColor: selectedButton == category
                                    ? primaryColor
                                    : secondaryColor,
                                minimumSize: const Size(100, 40),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (category == 'favoris') {
                                    widget.getIsFavorisSelected(true);
                                    Navigator.pop(context);
                                  }
                                  selectedButton = category;
                                  searchQuery = '';
                                });
                              },
                              child: Text(categoryTranslations[category]!),
                            ),
                          );
                        }).toList(),
                      ),
                      Expanded(
                        child: ListView(
                          children: _filtersManage().map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        arrayFiltersSelected[e['category']]
                                                    ?.contains(e['item']) ??
                                                false
                                            ? secondaryColor
                                            : primaryColor,
                                    foregroundColor:
                                        arrayFiltersSelected[e['category']]
                                                    ?.contains(e['item']) ??
                                                false
                                            ? primaryColor
                                            : secondaryColor),
                                onPressed: () => _filtersManageSelect(
                                    e['category']!, e['item']!),
                                child: Text(e['item']!),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25, top: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _resetBtnFilter
                        ? Colors.grey // Griser le bouton une fois désactivé
                        : primaryColor,
                    foregroundColor: secondaryColor,
                  ),
                  onPressed: _resetBtnFilter
                      ? null // Désactiver le bouton si la condition est remplie
                      : widget.isFavoritesSelected
                          ? () {
                              setState(() {
                                widget.getIsFavorisSelected(false);
                                _resetBtnFilter =
                                    true; // Désactiver le bouton après la première action
                              });
                            }
                          : isArrayFilterNotEmpty
                              ? () {
                                  setState(() {
                                    arrayFiltersSelected.forEach((key, value) =>
                                        arrayFiltersSelected[key] =
                                            []); // Réinitialiser les filtres
                                    _filtersSelectionSave();
                                    _resetBtnFilter =
                                        true; // Désactiver le bouton après la réinitialisation
                                  });
                                }
                              : null, // Rendre le bouton non cliquable si aucune condition n'est remplie
                  child: const Text(
                    'Réinitialiser les filtres',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          );
  }
}
