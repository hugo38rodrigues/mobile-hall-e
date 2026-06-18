import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/bar-minimal-informations.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientMap extends ConsumerStatefulWidget {
  final List<BarMinimalInformations> barMinimalInformations;
  final List barNameFavorites;
  final Function(String id, String name) handleStateBarNameFavorites;
  const ClientMap({
    super.key,
    required this.barMinimalInformations,
    required this.barNameFavorites,
    required this.handleStateBarNameFavorites,
  });

  @override
  ConsumerState<ClientMap> createState() => _ClientMapState();
}

class _ClientMapState extends ConsumerState<ClientMap> {
  final bool _isIos = Platform.isIOS;
  final PopupController _popupController = PopupController();

  Future<void> _openMapsWithDirections(BarMinimalInformations bar) async {
    final destination = Uri.encodeComponent(bar.address);
    final googleUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination');
    final appleUri = Uri.parse('maps://?daddr=$destination');

    try {
      if (_isIos && await canLaunchUrl(appleUri)) {
        await launchUrl(appleUri);
      } else {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Erreur ouverture Maps: $e");
    }
  }

  List<Marker> _buildBarMarkers() {
    return widget.barMinimalInformations.map((bar) {
      return Marker(
        point: LatLng(bar.latitude, bar.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _popupController.togglePopup(
            Marker(
                point: LatLng(bar.latitude, bar.longitude),
                child: const SizedBox()),
          ),
          child: const Icon(Icons.location_pin, color: Colors.blue, size: 30),
        ),
      );
    }).toList();
  }

  Widget _buildPopup(Marker marker, bool isNotGuest) {
    final bar = widget.barMinimalInformations.firstWhere(
      (b) =>
          b.latitude == marker.point.latitude &&
          b.longitude == marker.point.longitude,
    );
    final isFavorite =
        widget.barNameFavorites.any((f) => f["name"] == bar.name);

    return Card(
      elevation: 5,
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(bar.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: textGold)),
                const SizedBox(width: 10),
                if (isNotGuest)
                  GestureDetector(
                    onTap: () =>
                        widget.handleStateBarNameFavorites(bar.id, bar.name),
                    child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: textGold),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _openMapsWithDirections(bar),
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
                side: const BorderSide(color: textGold, width: 2),
              ),
              child: const Text("Se rendre à ce bar",
                  style:
                      TextStyle(color: textGold, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(accountProvider);
    final location = profile.userLocation;

    if (!location.isActivated) {
      return Container(
        padding: const EdgeInsets.all(50),
        child: const Text(
          "Si vous voulez profiter de la carte, il faut accepter la localisation.",
          maxLines: 2,
          style: TextStyle(color: textGold),
        ),
      );
    }

    final userLatLng = LatLng(location.latitude, location.longitude);
    final isNotGuest = profile.role != 'guest';

    const distanceCalc = Distance();

    final hasBarWithin5km = widget.barMinimalInformations.any((bar) {
      final distanceInMeters = distanceCalc.as(
        LengthUnit.Meter,
        userLatLng,
        LatLng(bar.latitude, bar.longitude),
      );
      return distanceInMeters <= 2000;
    });
    final initialZoom = hasBarWithin5km ? 15.0 : 13.0;

    return SizedBox(
      width: 350,
      height: 400,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: userLatLng,
          initialZoom: initialZoom,
          onTap: (_, __) => _popupController.hideAllPopups(),
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${dotenv.env['TOKEN_MAP_TILTER']}",
            userAgentPackageName: 'com.example.hall_e_mobile',
            tileProvider: NetworkTileProvider(),
          ),
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              popupController: _popupController,
              markers: _buildBarMarkers(),
              popupDisplayOptions: PopupDisplayOptions(
                builder: (context, marker) => _buildPopup(marker, isNotGuest),
              ),
            ),
          ),
          // Marqueur utilisateur
          MarkerLayer(
            markers: [
              Marker(
                point: userLatLng,
                width: 40,
                height: 40,
                child:
                    const Icon(Icons.my_location, color: Colors.red, size: 35),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
