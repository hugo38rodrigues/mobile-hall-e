import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/game.model.dart';
import 'package:hall_e_mobile/models/league.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FilterPage extends ConsumerStatefulWidget {
  final Function(Map<String, List<String>>) getSelectedFilters;

  const FilterPage({
    required this.getSelectedFilters,
    super.key,
  });

  @override
  ConsumerState<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  String? _userRole;
  String _selectedCategory = 'games';
  String _searchQuery = '';
  bool _isLoading = true;

  List<Game> _games = [];
  List<League> _leagues = [];
  List<Team> _teams = [];
  List<Map<String, dynamic>> _barNames = [];

  Map<String, List<String>> _selectedFilters = {
    'games': [],
    'leagues': [],
    'teams': [],
    'barName': [],
  };

  static const _categoryLabels = {
    'games': 'Jeux',
    'leagues': 'Compétitions',
    'teams': 'Équipes',
    'barName': 'Nom des bars',
    'favoris': 'Vos favoris',
  };

  // ──────────────────── LIFECYCLE ────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userRole == null) {
      _userRole = ref.read(accountProvider).role;
      _fetchFilters();
      _loadSavedFilters();
    }
  }

  // ──────────────────── API ────────────────────

  Future<void> _fetchFilters() async {
    final apiUrl = dotenv.env['API_URL'];
    try {
      final response = await request('$apiUrl/filters', 'GET')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final filter = Favorites.fromMapInitial(response.data);
        setState(() {
          _games = filter.games;
          _leagues = filter.leagues;
          _teams = filter.teams;
          if (_userRole == 'client') _barNames = filter.barName;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      await handleError(e, context);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ──────────────────── PERSISTENCE ────────────────────

  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFilters = {
        'games': prefs.getStringList('games') ?? [],
        'leagues': prefs.getStringList('leagues') ?? [],
        'teams': prefs.getStringList('teams') ?? [],
        'barName': prefs.getStringList('barName') ?? [],
      };
    });

    widget.getSelectedFilters(_selectedFilters);
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in ['games', 'leagues', 'teams', 'barName']) {
      await prefs.setStringList(key, _selectedFilters[key] ?? []);
    }
    widget.getSelectedFilters(_selectedFilters);
  }

  // ──────────────────── LOGIQUE FILTRES ────────────────────

  void _toggleFilter(String category, String item) {
    setState(() {
      final list = _selectedFilters[category]!;
      list.contains(item) ? list.remove(item) : list.add(item);
    });
    _saveFilters();
  }

  void _removeFilter(String category, String item) {
    setState(() => _selectedFilters[category]!.remove(item));
    _saveFilters();
  }

  void _resetFilters() {
    setState(
        () => _selectedFilters.forEach((key, _) => _selectedFilters[key] = []));
    _saveFilters();
  }

  void _applyFilters() {
    widget.getSelectedFilters(_selectedFilters);
    Navigator.pop(context);
  }

  void _onCategoryPressed(String category) {
    if (category == 'favoris') {
      final favorites = ref.read(accountProvider).favorites;

      if (favorites == null) {
        showErrorSnackBar(context, "Vous n'avez pas de favoris");
        return;
      }

      setState(() {
        _selectedFilters = {
          'games': favorites.games.map((g) => g.name).toList(),
          'leagues': favorites.leagues.map((l) => l.name).toList(),
          'teams': favorites.teams.map((t) => t.name).toList(),
          'barName': favorites.barName.map((b) => b['name'] as String).toList(),
        };
      });
      _saveFilters();
      return;
    }

    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
    });
  }

  List<Map<String, String>> _getFilterItems() {
    final allItems = [
      ..._games.map((g) => {'category': 'games', 'name': g.name}),
      ..._leagues.map((l) => {'category': 'leagues', 'name': l.name}),
      ..._teams.map((t) => {'category': 'teams', 'name': t.name}),
      if (_userRole == 'client')
        ..._barNames
            .map((b) => {'category': 'barName', 'name': b['name'] as String}),
    ];

    final filtered = _searchQuery.isNotEmpty
        ? allItems.where((e) =>
            e['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        : allItems.where((e) => e['category'] == _selectedCategory);

    final items = filtered.toList();
    items.sort((a, b) {
      final aSelected =
          _selectedFilters[a['category']]?.contains(a['name']) ?? false;
      final bSelected =
          _selectedFilters[b['category']]?.contains(b['name']) ?? false;
      return aSelected == bSelected ? 0 : (aSelected ? -1 : 1);
    });

    return items;
  }

  bool _isSelected(Map<String, String> item) =>
      _selectedFilters[item['category']]?.contains(item['name']) ?? false;

  bool get _hasActiveFilters =>
      _selectedFilters.values.any((list) => list.isNotEmpty);

  List<Map<String, String>> get _activeFilterChips {
    final result = <Map<String, String>>[];
    _selectedFilters.forEach((category, items) {
      for (final item in items) {
        result.add({'category': category, 'name': item});
      }
    });
    return result;
  }

  List<String> get _categories {
    final cats = ['games', 'leagues', 'teams'];
    if (_userRole == 'client') cats.add('barName');
    if (_userRole == 'client' || _userRole == 'bar') cats.add('favoris');
    return cats;
  }

  // ──────────────────── BUILD ────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          if (_hasActiveFilters) _buildActiveFiltersRecap(),
          SizedBox(height: 35),
          Expanded(child: _buildFiltersBody()),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersRecap() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(color: textGold),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres actifs (${_activeFilterChips.length})',
            style: const TextStyle(
                color: textWhite, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _activeFilterChips.map((filter) {
              return Chip(
                backgroundColor: background,
                labelStyle: const TextStyle(color: textGold, fontSize: 12),
                label: Text(filter['name']!),
                deleteIcon: const Icon(Icons.close, size: 14, color: textGold),
                onDeleted: () =>
                    _removeFilter(filter['category']!, filter['name']!),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filtrer vos matchs',
            style: TextStyle(
                fontSize: 20, color: textGold, fontWeight: FontWeight.w800),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: textGold,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        cursorColor: textGold,
        style: const TextStyle(color: textWhite),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: textGrey),
          hintText: 'Rechercher...',
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: textGrey),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: textGrey),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFiltersBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Column(
            children: _categories
                .map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedCategory == cat ? textGold : bgCard,
                          foregroundColor:
                              _selectedCategory == cat ? background : textWhite,
                          side: BorderSide(
                            color: _selectedCategory == cat
                                ? textGold
                                : textGrey, // couleur de la bordure
                            width: 2, // épaisseur
                          ),
                          minimumSize: const Size(150, 40),
                        ),
                        onPressed: () => _onCategoryPressed(cat),
                        child: Text(_categoryLabels[cat]!),
                      ),
                    ))
                .toList(),
          ),
          Expanded(
            child: ListView(
              children: _getFilterItems()
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isSelected(item) ? textGold : bgCard,
                            foregroundColor:
                                _isSelected(item) ? background : textWhite,
                            side: BorderSide(
                              color: _isSelected(item)
                                  ? textGold
                                  : textGrey, // couleur de la bordure
                              width: 2, // épaisseur
                            ),
                          ),
                          onPressed: () =>
                              _toggleFilter(item['category']!, item['name']!),
                          child: Text(item['name']!),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: background,
                foregroundColor: !_hasActiveFilters ? textWhite : textGold,
                disabledForegroundColor: textWhite,
                side: BorderSide(
                    color: !_hasActiveFilters ? textGrey : textGold, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: !_hasActiveFilters ? null : _resetFilters,
              child:
                  const Text('Réinitialiser', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: textGold,
                foregroundColor: background,
                side: BorderSide(color: textGold, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _applyFilters,
              child: const Text('Valider', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
