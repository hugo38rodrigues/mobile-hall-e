import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/map/map-wrapper.dart';
import 'package:hall_e_mobile/components/my-app-bar.component.dart';
import 'package:hall_e_mobile/models/bar-minimal-informations.model.dart';
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
  final List<BarMinimalInformations>? barList;
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
  List<String> gameFavorites = [];
  List<String> leagueFavorites = [];
  List<String> teamsFavorites = [];
  List<String> barNameFavorites = [];
  String idUser = "";

  @override
  void initState() {
    super.initState();
    getHoursAndDays();
    getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    bool isFavoriteGame = gameFavorites.contains(widget.gameName);
    bool isFavoriteLeague = leagueFavorites.contains(widget.leagueName);
    bool isFavoriteTeam1 = teamsFavorites.contains(widget.team1.name);
    bool isFavoriteTeam2 = teamsFavorites.contains(widget.team2.name);

    String role = ref.watch(accountProvider).role;
    bool isNotGuest = role != 'guest';
    bool isNotBar = role != 'bar';

    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          children: [
            /// === Header ===
            Container(
              margin: EdgeInsets.only(left: 30, top: 50),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(widget.gameName,
                          style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      if (isNotGuest)
                        GestureDetector(
                          onTap: () => toggleFavorite(
                              type: 'game', name: widget.gameName),
                          child: Icon(
                            isFavoriteGame
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: secondaryColor,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Text(days,
                            style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Compétitions:",
                          style:
                              TextStyle(color: secondaryColor, fontSize: 12)),
                      SizedBox(width: 10),
                      Text(widget.leagueName,
                          style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      if (isNotGuest)
                        GestureDetector(
                          onTap: () => toggleFavorite(
                              type: 'league', name: widget.leagueName),
                          child: Icon(
                            isFavoriteLeague
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: secondaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            /// === Teams Row ===
            Container(
              padding: EdgeInsets.only(top: 50),
              child: SizedBox(
                width: 350,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child:
                            buildTeamName(widget.team1.name, secondaryColor)),
                    if (isNotGuest)
                      GestureDetector(
                        onTap: () => toggleFavorite(
                            type: 'team',
                            name: widget.team1.name,
                            id: widget.team1.id),
                        child: Icon(
                          isFavoriteTeam1
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: secondaryColor,
                        ),
                      ),
                    SizedBox(width: 20),
                    buildMatchHour(),
                    SizedBox(width: 20),
                    if (isNotGuest)
                      GestureDetector(
                        onTap: () => toggleFavorite(
                            type: 'team',
                            name: widget.team2.name,
                            id: widget.team2.id),
                        child: Icon(
                          isFavoriteTeam2
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: secondaryColor,
                        ),
                      ),
                    Expanded(
                        child:
                            buildTeamName(widget.team2.name, secondaryColor)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            /// === Map or Message ===
            isNotBar
                ? (widget.barList?.isEmpty ?? true)
                    ? Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Text("Aucun bar ne programme ce match,",
                                style: TextStyle(
                                    fontSize: 15, color: secondaryColor)),
                            Text("n'hésitez pas à leur en parler",
                                style: TextStyle(
                                    fontSize: 15, color: secondaryColor)),
                          ],
                        ))
                    : MapWrapper(addressList: widget.barList!)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  /// === UI Helpers ===
  Widget buildTeamName(String name, Color color) => Text(
        name,
        textAlign: TextAlign.center,
        style:
            TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.visible,
      );

  Widget buildMatchHour() => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: secondaryColor, borderRadius: BorderRadius.circular(20)),
        child: Text(hours,
            style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      );

  void getHoursAndDays() {
    DateTime dateTime = DateTime.parse(widget.date).toLocal();
    setState(() {
      hours = DateFormat("HH'h'mm").format(dateTime);
      days =
          "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    });
  }

  void getFavorites() {
    User profile = ref.read(accountProvider);
    final fav = profile.favorites;
    if (profile.role != 'guest' && fav != null) {
      setState(() {
        gameFavorites = List<String>.from(fav.gameName);
        leagueFavorites = List<String>.from(fav.leagueName);
        teamsFavorites = fav.teams.map((t) => t.name).toList();
        idUser = profile.id;
        if (profile.role == 'client') {
          barNameFavorites = List<String>.from(fav.barName);
        }
      });
    }
  }

  Future<void> toggleFavorite(
      {required String type, required String name, String? id}) async {
    // ✅ Met à jour localement immédiatement
    setState(() {
      switch (type) {
        case 'game':
          gameFavorites.contains(name)
              ? gameFavorites.remove(name)
              : gameFavorites.add(name);
          break;
        case 'league':
          leagueFavorites.contains(name)
              ? leagueFavorites.remove(name)
              : leagueFavorites.add(name);
          break;
        case 'team':
          teamsFavorites.contains(name)
              ? teamsFavorites.remove(name)
              : teamsFavorites.add(name);
          break;
      }
    });

    // ✅ Appelle l'API correspondante
    try {
      switch (type) {
        case 'game':
          gameFavorites.contains(name)
              ? await addFavorite('gameName', name: name, id: id)
              : await deleteFavorite('gameName', name: name, id: id);
          break;
        case 'league':
          leagueFavorites.contains(name)
              ? await addFavorite('leagueName', name: name, id: id)
              : await deleteFavorite('leagueName', name: name, id: id);
          break;
        case 'team':
          teamsFavorites.contains(name)
              ? await addFavorite('teams', id: id)
              : await deleteFavorite('teams', id: id);
          break;
      }
    } catch (_) {}
  }

  Future<void> addFavorite(String type, {String? name, String? id}) async =>
      await _sendFavoriteRequest(type, 'POST', name: name, id:id);

  Future<void> deleteFavorite(String type, {String? name, String? id}) async =>
      await _sendFavoriteRequest(type, 'DELETE', name: name, id: id);

  Future<void> _sendFavoriteRequest(String type, String method,
      {String? name, String? id}) async {
    User profile = ref.read(accountProvider);
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    final path = '$apiUrl/favoris';
    final data = {
      "type": type,
      "idUser": idUser,
      if (name != null) "data": name,
      if (id != null) "data": id,
    };

    try {
      Response response = await (method == 'POST'
              ? dio.post(path, data: data, options: _options(profile.token))
              : dio.delete(path, data: data, options: _options(profile.token)))
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw DioException(
            requestOptions: RequestOptions(path: path),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout');
      });

      if (response.statusCode == 200) {
        ref
            .read(accountProvider.notifier)
            .updateAccount({'favorites': response.data});
      }
    } catch (e) {
      if (e is DioException && mounted) await handleError(e, context);
    }
  }

  Options _options(String token) => Options(headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      });
}
