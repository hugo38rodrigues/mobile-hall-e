import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
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

  List gameNames = [];
  List leagueNames = [];
  List teams = [];
  bool isLoading = false;
  String searchQuery = "";

  final Map<String, String> categoryTranslations = {
    'games': 'Jeux',
    'leagues': 'Compétitions',
    'teams': 'Équipes'
  };

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
      Response response = await dio.get('$apiUrl/commun/filters').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions:
                RequestOptions(path: '$apiUrl/commun/filters'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          gameNames = response.data['filters']['gameNames'] ?? [];
          leagueNames = response.data['filters']['leagueNames'] ?? [];
          teams = response.data['filters']['teamNames'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        // Appelle la fonction de gestion des erreurs
        handleError(e, context);
      }
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

  void _filtersManageSelect(String category, String item) {
    setState(() {
      List<String> selection = arrayFiltersSelected[category]!;
      selection.contains(item) ? selection.remove(item) : selection.add(item);
      _filtersSelectionSave();
    });
  }

  List<dynamic> _filtersManage() {
    List<dynamic> allItems = [
      ...gameNames.map((item) => {'category': 'games', 'item': item}),
      ...leagueNames.map((item) => {'category': 'leagues', 'item': item}),
      ...teams.map((item) => {'category': 'teams', 'item': item}),
    ];

    List<dynamic> filteredItems = searchQuery.isNotEmpty
        ? allItems
            .where((e) => e['item']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList()
        : allItems.where((e) => e['category'] == boutonSelectionne).toList();

    List<dynamic> selectedItems = filteredItems
        .where((e) =>
            arrayFiltersSelected[e['category']]?.contains(e['item']) ?? false)
        .toList();

    List<dynamic> unselectedItems = filteredItems
        .where((e) =>
            !(arrayFiltersSelected[e['category']]?.contains(e['item']) ??
                false))
        .toList();

    return [...selectedItems, ...unselectedItems];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            ),
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
                children: ['games', 'leagues', 'teams'].map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: boutonSelectionne == category
                            ? secondaryColor
                            : primaryColor,
                        foregroundColor: boutonSelectionne == category
                            ? primaryColor
                            : secondaryColor,
                        minimumSize: Size(100, 40),
                      ),
                      onPressed: () {
                        setState(() {
                          boutonSelectionne = category;
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
                            backgroundColor: arrayFiltersSelected[e['category']]
                                        ?.contains(e['item']) ??
                                    false
                                ? secondaryColor
                                : primaryColor,
                            foregroundColor: arrayFiltersSelected[e['category']]
                                        ?.contains(e['item']) ??
                                    false
                                ? primaryColor
                                : secondaryColor),
                        onPressed: () =>
                            _filtersManageSelect(e['category'], e['item']),
                        child: Text(e['item']),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        )),
        Padding(
          padding: const EdgeInsets.only(bottom: 25, top: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, foregroundColor: secondaryColor),
            onPressed:
                arrayFiltersSelected.values.any((list) => list.isNotEmpty)
                    ? () {
                        setState(() {
                          arrayFiltersSelected.forEach(
                              (key, value) => arrayFiltersSelected[key] = []);
                          _filtersSelectionSave();
                        });
                      }
                    : null,
            child: const Text('Réinitialiser les filtres',
                style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}
