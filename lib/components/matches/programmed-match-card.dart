import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/team.model.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:intl/intl.dart';

class ProgrammedMatchCard extends ConsumerStatefulWidget {
  final String idMatch;
  final String leagueName;
  final String gameName;
  final String date;
  final Team team2;
  final Team team1;
  final Function(String idMatch) getIdMatch;
  ProgrammedMatchCard(
      {required this.date,
      required this.gameName,
      required this.getIdMatch,
      required this.idMatch,
      required this.leagueName,
      required this.team1,
      required this.team2});

  @override
  _ProgrammedMatchCardState createState() => _ProgrammedMatchCardState();
}

class _ProgrammedMatchCardState extends ConsumerState<ProgrammedMatchCard> {
  String formatTime(String date) {
    // Forcer le parsing en UTC
    DateTime dateTime = DateTime.parse(date).toLocal();

    // Formatter l'heure sans conversion locale
    String formattedTime = DateFormat("HH'h'mm").format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    String hours = formatTime(widget.date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(1),
        child: InkWell(
          borderRadius: BorderRadius.circular(1),
          splashColor: secondaryColor,
          highlightColor: Color.fromRGBO(255, 255, 255, 0.1),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: secondaryColor, // Couleur de la bordure
                  width: 1.0, // Épaisseur de la bordure
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              elevation:
                  6, // Augmente légèrement l'élévation pour une meilleure ombre
              shadowColor: Color.fromRGBO(0, 0, 0, 0.2), // Ombre douce
              color: Colors.white, // Fond de la carte
              child: Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne supérieure : Nom de la ligue + Heure
                    Container(
                      decoration: BoxDecoration(color: primaryColor75),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 12, right: 12, top: 12, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.gameName,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: secondaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                hours,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // League
                    Container(
                      decoration: BoxDecoration(color: primaryColor50),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 12, right: 12, top: 12, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.leagueName.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryColor,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                widget.getIdMatch(widget.idMatch);
                              },
                              icon: Icon(Icons.close),
                              color: secondaryColor,
                            )
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
                                widget.team1.logoUrl.isNotEmpty
                                    ? Image.network(
                                        widget.team1.logoUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(Icons.add, size: 50),
                                SizedBox(width: 55),
                                Expanded(
                                  child: Text(
                                    widget.team1.name,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: secondaryColor,
                                        fontWeight: FontWeight.bold),
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
                                widget.team2.logoUrl.isNotEmpty
                                    ? Image.network(
                                        widget.team2.logoUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.add, size: 50),
                                SizedBox(width: 55),
                                Expanded(
                                    child: (Text(
                                  widget.team2.name,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: secondaryColor,
                                      fontWeight: FontWeight.bold),
                                )))
                              ])
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
