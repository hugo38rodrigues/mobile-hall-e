import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hall_e_mobile/components/bars-screen/bard-card.component.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class BarList extends ConsumerStatefulWidget {
  @override
  ConsumerState<BarList> createState() => _BarListState();
}

class _BarListState extends ConsumerState<BarList> {
  List<User> bars = [];
  bool isLoading = false;

  final Map<String, Map<String, double>> _geoCache = {};

  @override
  void initState() {
    super.initState();
    getBars();
  }

  Future<void> getBars() async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      Response response = await dio.get('$apiUrl/client/').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/client/'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        List<User> barList = (response.data['data'] as List)
            .map((bar) => User.fromMap(bar))
            .toList();
        if (mounted) {
          setState(() {
            bars = barList;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (e is DioException) {
        handleError(e, context);
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<Map<String, double>?> getLatLongFromAddressBar(String address) async {
    if (_geoCache.containsKey(address)) return _geoCache[address];

    try {
      Dio dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1',
        options: Options(headers: {'User-Agent': 'FlutterApp'}),
      );

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final coords = {
          'lat': double.parse(response.data[0]['lat']),
          'lon': double.parse(response.data[0]['lon']),
        };
        _geoCache[address] = coords;
        return coords;
      }
    } catch (e) {
      print("Erreur API: $e");
    }

    return null;
  }

  Future<List<User>> filterBarsWithinRadius(
    double latitudeUser,
    double longitudeUser,
    List<User> bars,
  ) async {
    List<User> filteredBars = [];

    for (final bar in bars) {
      
        Informations barInfo = bar.informations!;

        final double distance = Geolocator.distanceBetween(
          latitudeUser,
          longitudeUser,
          barInfo.latitude!,
          barInfo.longitude!,
        );

        final double distanceInKm = distance / 1000;

        if (distanceInKm <= 100) {
          filteredBars.add(bar);
        }
      
    }

    return filteredBars;
  }

  Future<List<User>> filterBarsWithActiveProgram(
    List<User> bars,
    double latitudeUser,
    double longitudeUser,
  ) async {
    final barsWithinRadius =
        await filterBarsWithinRadius(latitudeUser, longitudeUser, bars);

    return barsWithinRadius
        .where((bar) => bar.programations!.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final User profile = ref.watch(accountProvider);

    if (!profile.userLocation!.isActivated) {
      return Center(
        child: Text(
          "La localisation n'est pas activée.\nVeuillez l'activer pour voir les bars à proximité.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: secondaryColor),
        ),
      );
    }

    return isLoading
        ? Center(
            child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: CustomLoader(text: "Chargement des bars"),
            ),
          )
        : FutureBuilder<List<User>>(
            future: filterBarsWithActiveProgram(
              bars,
              profile.userLocation!.latitude,
              profile.userLocation!.longitude,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CustomLoader(text: "Filtrage en cours...");
              } else if (snapshot.hasError) {
                return Center(child: Text("Erreur lors du filtrage"));
              } else if (snapshot.data!.isEmpty) {
                return Center(
                  heightFactor: 25,
                  child: Text(
                    "Aucun bar ne programme de matches",
                    style: TextStyle(color: secondaryColor, fontSize: 16),
                  ),
                );
              } else {
                return Column(
                  children:
                      snapshot.data!.map((bar) => BarCard(bar: bar)).toList(),
                );
              }
            },
          );
  }
}
