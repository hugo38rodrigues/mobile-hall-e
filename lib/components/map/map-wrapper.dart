import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/user.models.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
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

  @override
  void initState() {
    super.initState();
    print(widget.addressList);
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

  @override
  Widget build(BuildContext context) {
    User profile = ref.watch(accountProvider);

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
                        return Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(geo['name'] ?? 'Bar inconnu',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {
                                    openMapsWithDirections(
                                        geo['address'] ?? 'Adresse inconnue',
                                        profile.userLocation.latitude!,
                                        profile.userLocation.longitude!);
                                  },
                                  child: Text("Se rendre à ce bar"),
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
