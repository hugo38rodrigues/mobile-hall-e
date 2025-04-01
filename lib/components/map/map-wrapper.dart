import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapWrapper extends StatefulWidget {
  final List addressList;

  MapWrapper({required this.addressList});

  @override
  _MapWrapperState createState() => _MapWrapperState();
}

class _MapWrapperState extends State<MapWrapper> {
  final PopupController _popupController = PopupController();
  List<Map<String, dynamic>> geoPositionList =
      []; // Liste des adresses et coordonnées
  LatLng? userPosition;
  bool locationDenied = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // Afficher un message si la localisation est désactivée
  void _showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Localisation désactivée"),
        content: Text(
            "Veuillez activer la localisation pour afficher votre position sur la carte."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Demander la permission et récupérer la position
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDisabledDialog();
      return;
    }
    void showPermissionDeniedMessage() {
      setState(() {
        locationDenied = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permission de localisation refusée"),
          backgroundColor: Colors.red,
        ),
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showPermissionDeniedMessage();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showPermissionDeniedMessage();
      return;
    }

    // Récupérer la position actuelle
    _fetchUserLocation();
    _fetchCoordinates();
  }

  // Récupérer la position actuelle de l'utilisateur
  Future<void> _fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Erreur localisation : $e");
    }
  }

  // Récupérer les coordonnées des adresses
  Future<void> _fetchCoordinates() async {
    for (var item in widget.addressList) {
      await getLatLongFromAddress(item['address'], item['name']);
    }
  }

  Future<void> getLatLongFromAddress(String address, String name) async {
    try {
      Dio dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1',
        options: Options(headers: {'User-Agent': 'FlutterApp'}),
      );

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        setState(() {
          geoPositionList.add({
            'latitude': double.parse(response.data[0]['lat']),
            'longitude': double.parse(response.data[0]['lon']),
            'name': name, // Ajoute le nom du bar
            'address': address, // Adresse associée
          });
        });
      }
    } catch (e) {
      print("Erreur API: $e");
    }
  }

  Future<void> openMapsWithDirections(String destinationAddress) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Générer l'URL pour Google Maps ou Apple Plans
      final Uri googleMapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&origin=$latitude,$longitude&destination=${Uri.encodeComponent(destinationAddress)}');
      final Uri appleMapsUri = Uri.parse(
          'https://maps.apple.com/?saddr=$latitude,$longitude&daddr=${Uri.encodeComponent(destinationAddress)}');

      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else {
        throw 'Aucune application de cartes trouvée';
      }
    } catch (e) {
      print("Erreur lors de l'ouverture de Maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 400,
      child: FlutterMap(
        options: MapOptions(
          initialCenter:
              userPosition ?? LatLng(44.83168784403052, -0.5690594467725951),
          initialZoom: 14.5,
          onTap: (_, __) => _popupController.hideAllPopups(),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          if (!locationDenied)
            MarkerLayer(
              markers: geoPositionList.map((geo) {
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
                    child:
                        Icon(Icons.location_pin, color: Colors.blue, size: 30),
                  ),
                );
              }).toList(),
            ),
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              popupController: _popupController,
              markers: geoPositionList.map((geo) {
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
                    child:
                        Icon(Icons.location_pin, color: Colors.blue, size: 30),
                  ),
                );
              }).toList(),
              popupDisplayOptions: PopupDisplayOptions(
                builder: (BuildContext context, Marker marker) {
                  final geo = geoPositionList.firstWhere(
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
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              openMapsWithDirections(
                                  geo['address'] ?? 'Adresse inconnue');
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
          if (userPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: userPosition!,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.my_location, color: Colors.red, size: 35),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
