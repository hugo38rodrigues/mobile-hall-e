import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hall_e_mobile/components/bars-screen/bard-card.component.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/user-factory.model.dart';
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
      Response response = await dio.get('$apiUrl/bars/').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/bars/'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        List<User> barList = (response.data as List)
            .map((bar) => UserFactory.createFromMap(bar))
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
        if (!mounted) return;

        await handleError(e, context);

        if (!mounted) return; // Vérifie encore après un await
        setState(() => isLoading = false);
      }
    }
  }

  Future<List<User>> filterBarsWithinRadius(
    double latitudeUser,
    double longitudeUser,
    List<User> bars,
  ) async {
    List<User> filteredBars = [];

    for (final bar in bars) {
      Location barLocalisations = bar.userLocation;
      final double distance = Geolocator.distanceBetween(
        latitudeUser,
        longitudeUser,
        barLocalisations.latitude,
        barLocalisations.longitude,
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
    bool isActivated = profile.userLocation.isActivated;
    double latitudeUser = profile.userLocation.latitude;
    double longitudeUser = profile.userLocation.longitude;

    if (!isActivated) {
      return Center(
        child: Text(
          "La localisation n'est pas activée.\nVeuillez l'activer pour voir les bars à proximité.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: secondaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: isLoading
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: CustomLoader(text: "Chargement des bars"),
              ),
            )
          : FutureBuilder<List<User>>(
              future: filterBarsWithActiveProgram(
                  bars, latitudeUser, longitudeUser),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomLoader(text: "Filtrage en cours...");
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur lors du filtrage"));
                } else if (snapshot.data!.isEmpty) {
                  return Center(
                      heightFactor: 25,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Aucun bar ne programme de matches à proximité",
                          style: TextStyle(color: secondaryColor, fontSize: 15),
                        ),
                      ));
                } else {
                  return Column(
                    children:
                        snapshot.data!.map((bar) => BarCard(bar: bar)).toList(),
                  );
                }
              },
            ),
    );
  }
}
