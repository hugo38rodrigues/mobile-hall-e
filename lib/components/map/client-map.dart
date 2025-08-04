import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientMap extends ConsumerStatefulWidget {
  final List addressList;
  final List barNameFavorites;
  final Function handleStateBarNameFavorites;

  ClientMap({
    required this.addressList,
    required this.barNameFavorites,
    required this.handleStateBarNameFavorites,
  });

  @override
  ConsumerState<ClientMap> createState() => _MapWrapperState();
}

class _MapWrapperState extends ConsumerState<ClientMap> {
  bool isIos = Platform.isIOS;
  late double latitudeUser;
  late double longitudeUser;
  final PopupController _popupController = PopupController();

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

  @override
  Widget build(BuildContext context) {
    User profile = ref.watch(accountProvider);
    bool isNotGuest = profile.role != 'guest';

    if (profile.userLocation.isActivated) {
      setState(() {
        longitudeUser = profile.userLocation.longitude;
        latitudeUser = profile.userLocation.latitude;
      });
    }

    return profile.userLocation.isActivated
        ? SizedBox(
            width: 350,
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitudeUser, longitudeUser),
                initialZoom: 15,
                onTap: (_, __) => _popupController.hideAllPopups(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${dotenv.env['TOKEN_MAP_TILTER']}",
                  userAgentPackageName:
                      'com.example.hall_e_mobile', // ← à adapter avec ton nom de package
                  tileProvider: NetworkTileProvider(),
                ),

                MarkerLayer(
                  markers: widget.addressList.map((geo) {
                    return Marker(
                      point: LatLng(geo.latitude, geo.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _popupController
                              .hideAllPopups(); // Ferme les autres popups
                          _popupController.togglePopup(Marker(
                            point: LatLng(geo.latitude, geo.longitude),
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
                        point: LatLng(geo.latitude, geo.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            _popupController
                                .hideAllPopups(); // Ferme les autres popups
                            _popupController.togglePopup(Marker(
                              point: LatLng(geo.latitude, geo.longitude),
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
                              g.latitude == marker.point.latitude &&
                              g.longitude == marker.point.longitude,
                        );
                        bool isFavorite =
                            widget.barNameFavorites.contains(geo.name);
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
                                    Text(geo.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: secondaryColor)),
                                    SizedBox(width: 10),
                                    Visibility(
                                      visible: isNotGuest,
                                      child: GestureDetector(
                                        onTap: () => {
                                          widget.handleStateBarNameFavorites(
                                              geo.id, geo.name)
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
                                    openMapsWithDirections(geo.address,
                                        latitudeUser, longitudeUser);
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
                      point: LatLng(latitudeUser, longitudeUser),
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
