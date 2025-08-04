import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/components/matches/programmed-match-card.dart';
import 'package:hall_e_mobile/models/programmation-match.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/date.dart';
import 'package:hall_e_mobile/utils/format-stream-url.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProgramationMatchList extends ConsumerStatefulWidget {
  @override
  _ProgramationMatchListState createState() => _ProgramationMatchListState();
}

class _ProgramationMatchListState extends ConsumerState<ProgramationMatchList> {
  bool isLoading = false;
  List<ProgrammationMatch> programmedMatches = [];

  @override
  void initState() {
    getProgrammationMatch();
    super.initState();
  }

  Future<void> getProgrammationMatch() async {
    User profile = ref.read(accountProvider);

    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      Response response = await dio
          .get('$apiUrl/bar/${profile.id}',
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer ${profile.token}"
                },
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/bar/${profile.id}'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> programmedMatchByBar = response.data as List;
        final programmedMatchList = programmedMatchByBar
            .map((match) => ProgrammationMatch.fromJson(match))
            .toList();
        setState(() {
          programmedMatches = programmedMatchList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);

        if (!mounted) return; // Vérifie encore après un await
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> deletedProgramations(idMatch) async {
    String token = ref.watch(accountProvider).token;
    String id = ref.watch(accountProvider).id;
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    try {
      Response response = await dio
          .delete('$apiUrl/bar/',
              data: {'matchId': idMatch, 'barId': id},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token"
                },
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/bars/'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        List<ProgrammationMatch> updatedList = programmedMatches
            .where((match) => !response.data.contains(match.id))
            .toList();
        setState(() {
          programmedMatches = updatedList;
        });
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);

        if (!mounted) return; // Vérifie encore après un await
        setState(() => isLoading = false);
      }
    }
  }

  void getIdMatch(idMatch) {
    deletedProgramations(idMatch);
  }

  Future<void> generateAndPrintPdf(
      List<ProgrammationMatch> programmedMatches) async {
    final pdf = pw.Document();
    final fontBold =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Lexend-Bold.ttf"));
    final font =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Lexend-Medium.ttf"));
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Programation des matchs Esport',
              style: pw.TextStyle(fontSize: 30, font: font)),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: [
              'Jeu',
              'Date',
              'Ligue',
              'Stream',
              'Hype Score',
              'Équipe 1',
              'Équipe 2',
            ],
            data: programmedMatches.map((match) {
              return [
                match.gameName,
                formatDate(match.date),
                match.leagueName,
                match.streamPlatform.map((match) => getStreamName(match)),
                match.hypeScore,
                match.team1.name,
                match.team2.name,
              ];
            }).toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(font: fontBold, fontSize: 8),
            tableWidth: pw.TableWidth.max,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEmptyProgrammedMatches = programmedMatches.isEmpty;
    programmedMatches.sort((a, b) {
      DateTime dateA = DateTime.parse(a.date);
      DateTime dateB = DateTime.parse(b.date);
      return dateA.compareTo(dateB);
    });
    return Scaffold(
      backgroundColor: primaryColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            isEmptyProgrammedMatches ? Colors.grey : secondaryColor,
        foregroundColor:
            Colors.white.withOpacity(isEmptyProgrammedMatches ? 0.5 : 1.0),
        onPressed: isEmptyProgrammedMatches
            ? null
            : () => generateAndPrintPdf(programmedMatches),
        child: Icon(
          Icons.picture_as_pdf,
          color: isEmptyProgrammedMatches ? Colors.white70 : primaryColor,
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CustomLoader(text: 'Récupération de vos matches programmés'))
          : programmedMatches.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: 80), // pour ne pas être caché par le FAB
                  itemCount: programmedMatches.length,
                  itemBuilder: (context, index) {
                    final ProgrammationMatch match = programmedMatches[index];
                    return ProgrammedMatchCard(
                      idMatch: match.id,
                      leagueName: match.leagueName,
                      gameName: match.gameName,
                      date: match.date,
                      team2: match.team2,
                      team1: match.team1,
                      hypeScore: match.hypeScore,
                      streamPlatform: match.streamPlatform,
                      getIdMatch: deletedProgramations,
                    );
                  },
                )
              : Center(
                  child: Text(
                    "Vous n'avez aucune programmation",
                    style: TextStyle(color: secondaryColor, fontSize: 18),
                  ),
                ),
    );
  }
}
