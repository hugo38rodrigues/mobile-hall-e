import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/programmationMatch.dart';
import 'package:hall_e_mobile/models/user.models.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class BarCard extends ConsumerStatefulWidget {
  final User bar;
  const BarCard({required this.bar});

  @override
  ConsumerState<BarCard> createState() => _BarCardState();
}

class _BarCardState extends ConsumerState<BarCard> {
  LatLng? userPosition;
  bool locationDenied = false;
  bool isIos = Platform.isIOS;

  @override
  void initState() {
    super.initState();
  }

  String getDate(String date) {
    DateTime dateTime = DateTime.parse(date).toLocal();
    int month = dateTime.month;
    int day = dateTime.day;
    int monthLenght = month.toString().length;
    int dayLenght = day.toString().length;
    String newMonth = monthLenght == 1 ? "0$month" : "$month";
    String newDay = dayLenght == 1 ? "0$day" : "$day";
    return "$newDay/$newMonth";
  }

  String getGame(String gameName) {
    switch (gameName) {
      case "Valorant":
        return "assets/gameLogos/valorant.png";
      case "League of legends":
        return "assets/gameLogos/lol.png";
      case "Cs go":
        return "assets/gameLogos/cs.png";
      default:
        return "assets/gameLogos/lol.png";
    }
  }

  String getHours(String date) {
    DateTime datetime = DateTime.parse(date).toLocal();
    int hours = datetime.hour;
    int mins = datetime.minute;
    String? formatedMins;

    if (mins.toString().length == 1) {
      formatedMins = '0$mins';
    }

    return '${hours}H${formatedMins ?? mins}';
  }

  List<ProgrammationMatch> filterByDateMatch(
      List<ProgrammationMatch> programmationMatches) {
    programmationMatches.sort((a, b) {
      DateTime dateA = DateTime.parse(a.date);
      DateTime dateB = DateTime.parse(b.date);
      return dateA.compareTo(dateB);
    });
    return programmationMatches;
  }

  Future<void> openMapsWithDirections(
      String destinationAddress, double latitude, double longitude) async {
    try {
      final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$latitude,$longitude&destination=${Uri.encodeComponent(destinationAddress)}',
      );
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
    double? userLatitude = profile.userLocation.latitude;
    double? userLongitude = profile.userLocation.longitude;
    BarInformationsModel informations =
        widget.bar.informations as BarInformationsModel;
    List<ProgrammationMatch> programmationMatch = widget.bar.programmations;

    return Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: secondaryColor, // Couleur de la bordure
          width: 1.0, // Épaisseur de la bordure
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white, // Beige clair
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: primaryColor),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      informations.name,
                      style: TextStyle(
                          fontSize: 15,
                          color: secondaryColor,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              child: Padding(
                padding:
                    EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                child: Column(
                  children: filterByDateMatch(programmationMatch)
                      .map(
                        (prog) => Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Répartit les éléments
                          children: [
                            SizedBox(
                              width: 60, // Taille fixe pour la date
                              child: Text(
                                getDate(prog.date),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: secondaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 15),
                            Image(
                              width: 30,
                              height: 30,
                              image: AssetImage(getGame(prog.gameName)),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Centre les équipes
                                children: [
                                  Text(
                                    prog.team1.acronym,
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'VS',
                                    style: TextStyle(color: secondaryColor),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    prog.team2.acronym,
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 70, // Taille fixe pour l'heure
                              child: Text(
                                getHours(prog.date),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: secondaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 2),
            Container(
              alignment: Alignment(0, 100),
              child: profile.userLocation.isActivated
                  ? SizedBox(
                      width: 175,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          openMapsWithDirections(
                              informations.address, userLatitude!, userLongitude!);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, elevation: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Trouver le bar",
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_circle_right_outlined,
                              size: 24,
                              color: secondaryColor,
                            )
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 210,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, elevation: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Activer la localisation",
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
