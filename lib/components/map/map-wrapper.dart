import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/user.models.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapWrapper extends ConsumerStatefulWidget {
  final List addressList;
  const MapWrapper({required this.addressList});

  @override
  ConsumerState<MapWrapper> createState() => _MapWrapperState();
}

class _MapWrapperState extends ConsumerState<MapWrapper> {
  final PopupController _popupController = PopupController();
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
        barNameFavorites = profile.favorites.barName;
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
    bool isNotGuest = profile.role != 'guest';

    return profile.userLocation.isActivated
        ? SizedBox(
            width: 350,
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(profile.userLocation.latitude!,
                    profile.userLocation.longitude!),
                initialZoom: 14.5,
                onTap: (_, __) => _popupController.hideAllPopups(),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),

                MarkerLayer(
                  markers: widget.addressList.map((geo) {
                    return Marker(
                      point: LatLng(geo['latitude'], geo['longitude']),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _popupController
                              .hideAllPopups(); // Ferme les autres popups
                          _popupController.togglePopup(Marker(
                            point: LatLng(geo['latitude'], geo['longitude']),
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_pin,
                                color: Colors.blue, size: 30),
                          ));
                        },
                        child: Icon(Icons.location_pin,
                            color: Colors.blue, size: 30),
                      ),
                    );
                  }).toList(),
                ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupController,
                    markers: widget.addressList.map((geo) {
                      return Marker(
                        point: LatLng(geo['latitude'], geo['longitude']),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            _popupController
                                .hideAllPopups(); // Ferme les autres popups
                            _popupController.togglePopup(Marker(
                              point: LatLng(geo['latitude'], geo['longitude']),
                              width: 40,
                              height: 40,
                              child: Icon(Icons.location_pin,
                                  color: Colors.blue, size: 30),
                            ));
                          },
                          child: Icon(Icons.location_pin,
                              color: Colors.blue, size: 30),
                        ),
                      );
                    }).toList(),
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        final geo = widget.addressList.firstWhere(
                          (g) =>
                              g['latitude'] == marker.point.latitude &&
                              g['longitude'] == marker.point.longitude,
                          orElse: () => {'name': 'Bar inconnu'},
                        );
                        bool isFavorite =
                            barNameFavorites.contains(geo['name']);
                        return Card(
                          elevation: 5,
                          color: primaryColor,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(geo['name'] ?? 'Bar inconnu',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: secondaryColor)),
                                    SizedBox(width: 10),
                                    Visibility(
                                      visible: isNotGuest,
                                      child: GestureDetector(
                                        onTap: () => {
                                          handleStateBarNameFavorites(
                                              geo['_id'], geo['name'])
                                        },
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          color: secondaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    openMapsWithDirections(
                                        geo['address'] ?? 'Adresse inconnue',
                                        profile.userLocation.latitude!,
                                        profile.userLocation.longitude!);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    side: BorderSide(
                                        color: secondaryColor,
                                        width: 2), // contour bleu
                                  ),
                                  child: Text(
                                    "Se rendre à ce bar",
                                    style: TextStyle(
                                        color: secondaryColor,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Ajouter le Marker pour l'utilisateur
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(profile.userLocation.latitude!,
                          profile.userLocation.longitude!),
                      width: 40,
                      height: 40,
                      child:
                          Icon(Icons.my_location, color: Colors.red, size: 35),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(50),
            child: Text(
              maxLines: 2,
              "Si vous voulez profiter de la carte, il faut accepter la localisation.",
              style: TextStyle(
                color: secondaryColor,
              ),
            ));
  }
}
