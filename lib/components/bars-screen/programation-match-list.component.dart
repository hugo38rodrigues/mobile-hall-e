import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/matches/match-card.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/models/match.model.dart';

class ProgramationMatchList extends ConsumerStatefulWidget {
  @override
  _ProgramationMatchListState createState() => _ProgramationMatchListState();
}

class _ProgramationMatchListState extends ConsumerState<ProgramationMatchList> {
  bool isLoading = false;
  late List<Match> programmedMatches;

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
        setState(() {
          programmedMatches = response.data.programationMatch;
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

  void deletedProgramations() {}

  @override
  Widget build(BuildContext context) {
    String role = ref.watch(accountProvider).role;

    programmedMatches.sort((a, b) {
      DateTime dateA = DateTime.parse(a.date);
      DateTime dateB = DateTime.parse(b.date);
      return dateA.compareTo(dateB);
    });

    return Center(
      child: Column(
        children: programmedMatches.map(
          (match) {
            return MatchCard(
                role: role,
                idMatch: match.id,
                leagueName: match.leagueName,
                gameName: match.gameName,
                programmed: [],
                date: match.date,
                team2: match.team2,
                team1: match.team1,
                getIdMatch: deletedProgramations);
          },
        ).toList(),
      ),
    );
  }
}
