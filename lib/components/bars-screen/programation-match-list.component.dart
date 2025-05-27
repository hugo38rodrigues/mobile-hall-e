import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/matches/programmed-match-card.dart';
import 'package:hall_e_mobile/models/match.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class ProgramationMatchList extends ConsumerStatefulWidget {
  @override
  _ProgramationMatchListState createState() => _ProgramationMatchListState();
}

class _ProgramationMatchListState extends ConsumerState<ProgramationMatchList> {
  bool isLoading = false;
  List programmedMatches = [];

  @override
  void initState() {
    getProgrammationMatch();
    super.initState();
  }

  Future<void> getProgrammationMatch() async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      Response response = await dio.get('$apiUrl/client/').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/client/'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> barList = response.data as List;
        final allMatchesTyped = barList
            .expand((bar) => bar['programmedMatches'] as List)
            .map((match) => Match.fromJson(match))
            .toList();
        setState(() {
          programmedMatches = allMatchesTyped;
        });
      }
    } catch (e) {
      if (e is DioException) {
        handleError(e, context);
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<void> deletedProgramations(idMatch) async {
    String id = ref.watch(accountProvider).id;
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    try {
      Response response = await dio.delete('$apiUrl/bar/',
          data: {'matchId': idMatch, 'barId': id}).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/bar/'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        List updatedList = programmedMatches
            .where((match) => !response.data.contains(match.id))
            .toList();
        setState(() {
          programmedMatches = updatedList;
        });
        print(updatedList);
      }
    } catch (e) {
      if (e is DioException) {
        handleError(e, context);
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  void getidMatch(idMatch) {
    deletedProgramations(idMatch);
  }

  @override
  Widget build(BuildContext context) {
    programmedMatches.sort((a, b) {
      DateTime dateA = DateTime.parse(a.date);
      DateTime dateB = DateTime.parse(b.date);
      return dateA.compareTo(dateB);
    });

    return Center(
      child: Column(
        children: programmedMatches.isNotEmpty
            ? programmedMatches.map(
                (match) {
                  return ProgrammedMatchCard(
                    idMatch: match.id,
                    leagueName: match.leagueName,
                    gameName: match.gameName,
                    date: match.date,
                    team2: match.team2,
                    team1: match.team1,
                    getIdMatch: deletedProgramations,
                  );
                },
              ).toList()
            : [
                Center(
                  heightFactor: 20,
                  child: Text(
                    "Vous n'avez aucune programmation",
                    style: TextStyle(color: secondaryColor, fontSize: 18),
                  ),
                )
              ],
      ),
    );
  }
}
