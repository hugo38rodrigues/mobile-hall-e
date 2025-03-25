import 'package:flutter/material.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/programmationMatch.dart';
import 'package:hall_e_mobile/models/user.models.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class BarCard extends StatefulWidget {
  final User bar;
  BarCard({required this.bar});

  @override
  _BardCardState createState() => _BardCardState();
}

class _BardCardState extends State<BarCard> {
  
  String getDate(String date) {
    DateTime dateTime = DateTime.parse(date);
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

  @override
  Widget build(BuildContext context) {
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
                  children: programmationMatch
                      .map((prog) => Row(
                            children: [
                              Container(
                                alignment: Alignment(0, 0),
                                child: Text(
                                  getDate(prog.date), // Affiche le nom du match
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: secondaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Image(
                              //   width: 30,
                              //   height: 30,
                              //   image: AssetImage(
                              //     getGame(prog.gameName),
                              //   ),
                              // ),
                              SizedBox(width: 10),
                              Container(
                                margin: EdgeInsets.only(left: 40),
                                child: Row(
                                  children: [
                                    Text(
                                      prog.team1
                                          .acronym, // Affiche le nom du match
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: secondaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'VS', // Affiche le nom du match
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: secondaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      prog.team2
                                          .acronym, // Affiche le nom du match
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: secondaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  getHours(prog.date),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: secondaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 2),
            Container(
                alignment: Alignment(0, 100),
                child: SizedBox(
                  width: 175,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, elevation: 4),
                    child: Row(
                      children: [
                        Text(
                          'Trouver le bar',
                          style: TextStyle(
                              color: secondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(
                          Icons.arrow_circle_right_outlined,
                          size: 24,
                          color: secondaryColor,
                        )
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
