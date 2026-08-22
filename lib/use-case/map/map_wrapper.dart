import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/use-case/map/client_map.dart';
import 'package:hall_e_mobile/models/bar-minimal-informations.model.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class MapWrapper extends ConsumerStatefulWidget {
  final List<BarMinimalInformations> barMinimalInformations;
  const MapWrapper({super.key, required this.barMinimalInformations});

  @override
  ConsumerState<MapWrapper> createState() => _MapWrapperState();
}

class _MapWrapperState extends ConsumerState<MapWrapper> {
  late final Dio _dio;
  List<Map<String, dynamic>> _barNameFavorites = [];

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _loadBarNameFavorites();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  void _loadBarNameFavorites() {
    final profile = ref.read(accountProvider);
    if (profile.role == 'guest' || profile.favorites == null) return;
    setState(() => _barNameFavorites = List.of(profile.favorites!.barName));
  }

  Future<void> handleStateBarNameFavorites(String idBar, String barName) async {
    final isPresent = _barNameFavorites.any((bar) => bar['name'] == barName);

    setState(() {
      isPresent
          ? _barNameFavorites.removeWhere((bar) => bar['name'] == barName)
          : _barNameFavorites.add({'id': idBar, 'name': barName});
    });

    try {
      await _sendBarNameFavoriteRequest(idBar: idBar, isPresent: isPresent);
    } catch (_) {
      setState(() {
        isPresent
            ? _barNameFavorites.add({'id': idBar, 'name': barName})
            : _barNameFavorites.removeWhere((bar) => bar['name'] == barName);
      });
    }
  }

  Future<void> _sendBarNameFavoriteRequest({
    required String idBar,
    required bool isPresent,
  }) async {
    final profile = ref.read(accountProvider);
    final apiUrl = dotenv.env['API_URL'];
    final path = '$apiUrl/favoris';

    final options = Options(headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}',
    });

    try {
      final response = await (isPresent
          ? _dio.delete(path,
              data: {'userId': profile.id, 'id': idBar, 'type': 'barName'},
              options: options)
          : request(
                  path,
                  data: {'userId': profile.id, 'id': idBar, 'type': 'barName'},
                  'POST',
                  token: profile.token)
              .timeout(const Duration(seconds: 10)));

      if (response.statusCode == 200) {
        final currentFav = profile.favorites ?? Favorites.empty();
        ref.read(accountProvider.notifier).updateAccount({
          'favorites': currentFav.copyWith(barName: _barNameFavorites).toJson(),
        });
      }
    } on DioException catch (e) {
      if (mounted) await handleError(e, context);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(accountProvider);

    if (profile.role == 'bar') return const SizedBox();

    return ClientMap(
      barMinimalInformations: widget.barMinimalInformations,
      barNameFavorites: _barNameFavorites,
      handleStateBarNameFavorites: handleStateBarNameFavorites,
    );
  }
}
