import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/map/client-map.dart';
import 'package:hall_e_mobile/models/programation-match.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:url_launcher/url_launcher.dart';

class MapWrapper extends ConsumerStatefulWidget {
  final List<ProgramationMatch> addressList;
  const MapWrapper({required this.addressList});

  @override
  ConsumerState<MapWrapper> createState() => _MapWrapperState();
}

class _MapWrapperState extends ConsumerState<MapWrapper> {
  bool isIos = Platform.isIOS;
  List barNameFavorites = [];
  String idUser = "";
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    getFavoritesBarName();
  }

  getFavoritesBarName() {
    User profile = ref.read(accountProvider);
    if (profile.role != 'guest') {
      setState(() {
        barNameFavorites = profile.favorites!.barName;
        idUser = profile.id;
        isConnected = true;
      });
    }
  }

  Future<void> openMapsWithDirections(
      String destinationAddress, double latitude, double longitude) async {
    try {
      // Générer l'URL pour Google Maps ou Apple Plans
      final Uri googleMapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&origin=$latitude,$longitude&destination=${Uri.encodeComponent(destinationAddress)}');
      final Uri appleMapsUri = Uri.parse(
        'maps://?saddr=$latitude,$longitude&daddr=${Uri.encodeComponent(destinationAddress)}',
      );

      if (isIos && await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else {
        await launchUrl(googleMapsUri);
      }
    } catch (e) {
      print("Erreur lors de l'ouverture de Maps: $e");
    }
  }

  handleStateBarNameFavorites(idBar, barName) async {
    bool barNameIsPresent = barNameFavorites.any((bar) => bar == barName);
    barNameIsPresent
        ? await deletedFavoriteBarName(idBar)
        : await addFavoriteBarName(idBar);
  }

  addFavoriteBarName(idBar) async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .post('$apiUrl/favorites/bar-name',
              data: {"idUser": idUser, "idBar": idBar},
              options: Options(
                headers: {"Content-Type": "application/json"},
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/connexion'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        ref
            .read(accountProvider.notifier)
            .updateAccount({'favorites': response.data});

        getFavoritesBarName();
      }
    } catch (e) {
      if (e is DioException) {
        // Appelle la fonction de gestion des erreurs
        handleError(e, context);
      }
    }
  }

  deletedFavoriteBarName(String idBar) async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .delete('$apiUrl/favorites/bar-name',
              data: {"idUser": idUser, "idBar": idBar},
              options: Options(
                headers: {"Content-Type": "application/json"},
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/favorites/bar-name'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        ref
            .read(accountProvider.notifier)
            .updateAccount({'favorites': response.data});
        getFavoritesBarName();
      }
    } catch (e) {
      if (e is DioException) {
        handleError(e, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User profile = ref.watch(accountProvider);
    bool isNotBar = profile.role != "bar";

    return isNotBar  
        ? ClientMap(
            barNameFavorites: barNameFavorites,
            handleStateBarNameFavorites: handleStateBarNameFavorites,
            addressList: widget.addressList,
          )
        : SizedBox();
  }
}
