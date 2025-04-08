import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/map/map-wrapper.dart';
import 'package:hall_e_mobile/components/my-app-bar.component.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:intl/intl.dart';

class MatchDetailsPage extends StatefulWidget {
  final String leagueName;
  final String gameName;
  final String date;
  final List<dynamic> barList;
  final String team1;
  final String team2;

  MatchDetailsPage({
    required this.leagueName,
    required this.gameName,
    required this.date,
    required this.team1,
    required this.team2,
    required this.barList,
  });
  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  bool isFavorite = false;
  String hours = '';
  String days = '';

  @override
  void initState() {
    super.initState();
    getHoursAndDays();
  }

  getHoursAndDays() {
    DateTime dateTime = DateTime.parse(widget.date).toLocal();
    String hour = DateFormat("HH'h'mm").format(dateTime);
    String day = dateTime.day.toString();
    String month = dateTime.month.toString().length == 1
        ? "0${dateTime.month.toString()}"
        : dateTime.month.toString();
    String year = dateTime.year.toString();

    setState(() {
      hours = hour;
      days = "$day/$month/$year";
    });
  }

  addFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 30, top: 50),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.gameName,
                        style: TextStyle(
                            color: secondaryColor, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: addFavorite,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: secondaryColor,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(
                            right: 20.0), // Ajoute un espace à droite
                        child: Text(
                          days,
                          style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Compétitions:",
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.leagueName,
                        style: TextStyle(
                            color: secondaryColor, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: addFavorite,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: secondaryColor,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 50),
              child: SizedBox(
                width:
                    350, // Ajuste la largeur max pour éviter les compressions
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.team1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // Permet le retour à la ligne
                        maxLines: 2, // Affiche max 2 lignes
                        overflow: TextOverflow.visible, // Évite "..."
                      ),
                    ),
                    GestureDetector(
                      onTap: addFavorite,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: secondaryColor,
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hours,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: addFavorite,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: secondaryColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.team2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow
                            .visible, // Affiche toute la ligne sans "..."
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            widget.barList.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text(
                          "Aucun bar ne programme ce match,",
                          style: TextStyle(fontSize: 15, color: secondaryColor),
                        ),
                        Text(
                          "n'hésité pas à leurs en parlez",
                          style: TextStyle(fontSize: 15, color: secondaryColor),
                        ),
                      ],
                    ))
                : MapWrapper(
                    addressList: widget.barList,
                  )
          ],
        ),
      ),
    );
  }
}
