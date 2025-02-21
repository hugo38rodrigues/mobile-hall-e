import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/fontColors.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatelessWidget {
  final String idMatch;
  final List<dynamic> programmed;
  final String leagueName;
  final String gameName;
  final String date;
  final String team1Acronym;
  final String? team1Logo;
  final String team1Name;
  final String team2Acronym;
  final String? team2Logo;
  final String team2Name;

  const MatchCard({
    required this.idMatch,
    required this.programmed,
    required this.leagueName,
    required this.gameName,
    required this.date,
    required this.team1Acronym,
    required this.team1Logo,
    required this.team1Name,
    required this.team2Acronym,
    required this.team2Logo,
    required this.team2Name,
    Key? key,
  }) : super(key: key);

  String formatTime(String date) {
    // Forcer le parsing en UTC
    DateTime dateTime = DateTime.parse(date).toLocal();

    // Formatter l'heure sans conversion locale
    String formattedTime = DateFormat("HH'h'mm").format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    var hours = formatTime(date);

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
            // Ligne supérieure : Nom de la ligue + Heure
            Container(
                decoration: BoxDecoration(color: primaryColor75),
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gameName,
                        style: TextStyle(fontSize: 18, color: Colors.brown),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hours,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),

            // League + Bouton "Trouver un bar"
            Container(
              decoration: BoxDecoration(color: primaryColor50),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      leagueName.toUpperCase(),
                      style: TextStyle(fontSize: 14, color: Colors.brown),
                    ),
                    if (programmed.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {}, // Action à définir
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            backgroundColor: primaryColor,
                            shadowColor: primaryColor,
                            elevation: 4,
                            side: BorderSide(
                                color: secondaryColor, // Couleur de la bordure
                                width: 1.0)),
                        child: Row(
                          children: [
                            Text(
                              "Trouver un bar",
                              style: TextStyle(
                                  color: secondaryColor, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),

            // Bloc des équipes centré
            Container(
              alignment: Alignment.center, // Centre verticalement
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 40),
                        team1Logo != null
                            ? Image.network(
                                team1Logo!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              )
                            : Icon(Icons.add, size: 50),
                        SizedBox(width: 55),
                        Expanded(
                          child: Text(
                            team1Name,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, color: Colors.brown.shade700),
                          ),
                        )
                      ]),
                  SizedBox(height: 6),
                  Divider(color: Colors.brown.shade200, thickness: 1),
                  SizedBox(height: 6),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 40),
                        team2Logo != null
                            ? Image.network(
                                team2Logo!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.add, size: 50),
                        SizedBox(width: 55),
                        Expanded(
                            child: (Text(
                          team2Name,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16, color: Colors.brown.shade700),
                        )))
                      ])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
