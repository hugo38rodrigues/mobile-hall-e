import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hall_e_mobile/use-case/bars-screen/bard-card.component.dart';
import 'package:hall_e_mobile/use-case/loader.component.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class BarList extends ConsumerStatefulWidget {
  const BarList({super.key});

  @override
  ConsumerState<BarList> createState() => _BarListState();
}

class _BarListState extends ConsumerState<BarList> {
  static const _maxDistanceKm = 15.0;
  static const _timeout = Duration(seconds: 10);

  List<BarUser> _bars = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  // ──────────────────── API ────────────────────

  Future<void> _loadBars() async {
    final profile = ref.read(accountProvider);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bars = await _fetchBars();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (bars == null || bars.isEmpty) {
          _error = "Aucun bar n'est inscrit autour de vous pour le moment";
        } else {
          _bars = _filterByDistance(
            bars,
            profile.userLocation.latitude,
            profile.userLocation.longitude,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Erreur lors du chargement";
      });
    }
  }

  Future<List<BarUser>?> _fetchBars() async {
    final apiUrl = dotenv.env['API_URL'];
    try {
      final response = await request('$apiUrl/bars/', 'GET').timeout(_timeout);

      if (response.statusCode == 200) {
        if (response.data == null) return null;
        return (response.data as List)
            .map((bar) => BarUser.fromMap(bar))
            .toList();
      }
      return null;
    } on DioException catch (e) {
      if (!mounted) return null;
      await handleError(e, context);
      return null;
    }
  }

  // ──────────────────── FILTRE ────────────────────

  double _getDistance(User bar, double lat, double lng) {
    return Geolocator.distanceBetween(
          lat,
          lng,
          bar.userLocation.latitude,
          bar.userLocation.longitude,
        ) /
        1000;
  }

  List<BarUser> _filterByDistance(List<BarUser> bars, double lat, double lng) {
    return bars.where((bar) {
      if (bar.programations == null || bar.programations!.isEmpty) return false;
      return _getDistance(bar, lat, lng) <= _maxDistanceKm;
    }).toList()
      ..sort((a, b) =>
          _getDistance(a, lat, lng).compareTo(_getDistance(b, lat, lng)));
  }

  // ──────────────────── BUILD ────────────────────

  @override
  Widget build(BuildContext context) {
    final isActivated = ref.watch(accountProvider).userLocation.isActivated;

    if (!isActivated) {
      return const Center(
        child: Text(
          "La localisation n'est pas activée.\n"
          "Veuillez l'activer pour voir les bars à proximité.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: textGold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: CustomLoader(text: "Chargement des bars"),
        ),
      );
    }

    if (_error != null) {
      final isSystemError = _error == "Erreur lors du chargement";
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textGold, fontSize: 15),
            ),
            if (isSystemError) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBars,
                child: const Text("Réessayer"),
              ),
            ],
          ],
        ),
      );
    }

    if (_bars.isEmpty) {
      return const Center(
        child: Text(
          "Aucun bar ne programme de matches à proximité",
          textAlign: TextAlign.center,
          style: TextStyle(color: textGold, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      itemCount: _bars.length,
      itemBuilder: (_, index) => BarCard(bar: _bars[index]),
    );
  }
}
