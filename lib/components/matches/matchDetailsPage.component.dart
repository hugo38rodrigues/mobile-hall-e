import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/map/map-wrapper.dart';
import 'package:hall_e_mobile/components/my-app-bar.component.dart';
import 'package:hall_e_mobile/models/programation-match.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:intl/intl.dart';

class MatchDetailsPage extends ConsumerStatefulWidget {
  final String leagueName;
  final String gameName;
  final String date;
  final List<ProgramationMatch>? barList;
  final Team team1;
  final Team team2;

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

class _MatchDetailsPageState extends ConsumerState<MatchDetailsPage> {
  String hours = '';
  String days = '';
  bool isConnected = false;
  List gameFavorites = [];
  List leagueFavorites = [];
  List<String> teamsFavorites = [];
  List barNameFavorites = [];
  String idUser = "";

  @override
  void initState() {
    super.initState();
    getHoursAndDays();
    getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    bool isFavoriteGame =
        gameFavorites.any((gameInArray) => gameInArray == widget.gameName);
    bool isFavoriteLeague = leagueFavorites
        .any((leagueInArray) => leagueInArray == widget.leagueName);
    bool isFavoriteTeam1 =
        teamsFavorites.any((team1InArray) => team1InArray == widget.team1.name);
    bool isFavoriteTeam2 =
        teamsFavorites.any((team2InArray) => team2InArray == widget.team2.name);
    String role = ref.watch(accountProvider).role;
    bool isNotGuest = role != 'guest';
    bool isNotBar = role != 'bar';

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
                      Visibility(
                        visible: isNotGuest,
                        child: GestureDetector(
                          onTap: () =>
                              handleStateGameFavorites(widget.gameName),
                          child: Icon(
                            isFavoriteGame
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: secondaryColor,
                          ),
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
                      Visibility(
                        visible: isNotGuest,
                        child: GestureDetector(
                          onTap: () =>
                              {handleStateLeagueFavorites(widget.leagueName)},
                          child: Icon(
                            isFavoriteLeague
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: secondaryColor,
                          ),
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
                        widget.team1.name,
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
                    Visibility(
                      visible: isNotGuest,
                      child: GestureDetector(
                        onTap: () => {
                          handleStateTeamFavorites(
                              widget.team1.name, widget.team1.id)
                        },
                        child: Icon(
                          isFavoriteTeam1
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: secondaryColor,
                        ),
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
                    Visibility(
                      visible: isNotGuest,
                      child: GestureDetector(
                        onTap: () => {
                          handleStateTeamFavorites(
                              widget.team2.name, widget.team2.id)
                        },
                        child: Icon(
                          isFavoriteTeam2
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.team2.name,
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
            isNotBar
                ? widget.barList!.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Text(
                              "Aucun bar ne programme ce match,",
                              style: TextStyle(
                                  fontSize: 15, color: secondaryColor),
                            ),
                            Text(
                              "n'hésité pas à leurs en parlez",
                              style: TextStyle(
                                  fontSize: 15, color: secondaryColor),
                            ),
                          ],
                        ))
                    : MapWrapper(
                        addressList: widget.barList!,
                      )
                : SizedBox()
          ],
        ),
      ),
    );
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

  getFavorites() {
    User profile = ref.read(accountProvider);
    if (profile.role != 'guest') {
      setState(() {
        gameFavorites = profile.favorites!.gameName;
        leagueFavorites = profile.favorites!.leagueName;
        teamsFavorites =
            profile.favorites!.teams.map((team) => team.name).toList();
        barNameFavorites = profile.favorites!.barName;
        idUser = profile.id;
        isConnected = true;
      });
    }
  }

  addFavoriteGame(gameName) async {
    User profile = ref.read(accountProvider);
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .post('$apiUrl/favorites/game',
              data: {
                "idUser": idUser,
                "gameName": gameName,
                "token": profile.token
              },
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer ${profile.token}'
                },
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

        getFavorites();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  addFavoriteLeague(leagueName) async {
    User profile = ref.read(accountProvider);
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .post('$apiUrl/favorites/league',
              data: {"idUser": idUser, "leagueName": leagueName},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer ${profile.token}'
                },
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

        getFavorites();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  addFavoriteTeam(idTeam) async {
    User profile = ref.read(accountProvider);
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .post('$apiUrl/favorites/team',
              data: {"idUser": idUser, "idTeam": idTeam},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer ${profile.token}'
                },
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
        getFavorites();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  deleteFavoriteGame(gameName) async {
    User profile = ref.read(accountProvider);
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .delete('$apiUrl/favorites/game',
              data: {"idUser": idUser, "gameName": gameName},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer ${profile.token}'
                },
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
        getFavorites();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  deleteFavoriteLeague(leagueName) async {
    User profile = ref.read(accountProvider);
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .delete('$apiUrl/favorites/league',
              data: {
                "idUser": idUser,
                "leagueName": leagueName,
                "token": profile.token
              },
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer ${profile.token}'
                },
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
        getFavorites();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  deleteFavoriteTeam(idTeam) async {
    User profile = ref.read(accountProvider);
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio
          .delete('$apiUrl/favorites/team',
              data: {
                "idUser": idUser,
                "idTeam": idTeam,
              },
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer ${profile.token}'
                },
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
        getFavorites();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;
        await handleError(e, context);
      }
    }
  }

  handleStateGameFavorites(gameName) async {
    bool gameIsPresent = gameFavorites.any((game) => game == gameName);
    gameIsPresent
        ? await deleteFavoriteGame(gameName)
        : await addFavoriteGame(gameName);
  }

  handleStateLeagueFavorites(leagueName) async {
    bool leagueIsPresent =
        leagueFavorites.any((league) => league == leagueName);
    leagueIsPresent
        ? await deleteFavoriteLeague(leagueName)
        : await addFavoriteLeague(leagueName);
  }

  handleStateTeamFavorites(teamName, teamId) async {
    bool teamIsPresent = teamsFavorites.any((team) => team == teamName);
    teamIsPresent
        ? await deleteFavoriteTeam(teamId)
        : await addFavoriteTeam(teamId);
  }
}
