import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/loader.component.dart';
import 'package:hall_e_mobile/components/matches/programmed_match_card.dart';
import 'package:hall_e_mobile/models/programmation-match.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/services/programmation.services.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/date.dart';
import 'package:hall_e_mobile/utils/format-stream-url.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MyProgramationMatchList extends ConsumerStatefulWidget {
  const MyProgramationMatchList({super.key});

  @override
  _MyProgramationMatchListState createState() =>
      _MyProgramationMatchListState();
}

class _MyProgramationMatchListState
    extends ConsumerState<MyProgramationMatchList> {
  final ProgrammationService _service = ProgrammationService();

  bool isLoading = false;
  List<ProgrammationMatch> programmedMatches = [];

  List<ProgrammationMatch> get sortedMatches => [...programmedMatches]
    ..sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

  @override
  void initState() {
    super.initState();
    _fetchProgrammations();
  }

  Future<void> _fetchProgrammations() async {
    final User profile = ref.read(accountProvider);

    setState(() => isLoading = true);

    try {
      final matches = await _service.fetchByBar(profile.id, profile.token);
      if (!mounted) return;
      setState(() => programmedMatches = matches);
    } on DioException catch (e) {
      if (!mounted) return;
      await handleError(e, context);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteProgramation(String idMatch) async {
    final User profile = ref.read(accountProvider);

    try {
      await _service.deleteProgramation(idMatch, profile.id, profile.token);
      if (!mounted) return;
      setState(() {
        programmedMatches.removeWhere((match) => match.id == idMatch);
      });
    } on DioException catch (e) {
      if (!mounted) return;
      await handleError(e, context);
    }
  }

  Future<void> _generateAndPrintPdf() async {
    final pdf = pw.Document();
    final fontBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Lexend-Bold.ttf'));
    final font =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Lexend-Medium.ttf'));

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Programation des matchs Esport',
            style: pw.TextStyle(fontSize: 30, font: font),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: [
              'Jeu',
              'Date',
              'Ligue',
              'Stream',
              'Hype Score',
              'Équipe 1',
              'Équipe 2'
            ],
            data: sortedMatches
                .map((match) => [
                      match.game.name,
                      formatDate(match.date),
                      match.league.name,
                      match.streamPlatform.map(getStreamName).join(', '),
                      match.hypeScore,
                      match.team1.name,
                      match.team2.name,
                    ])
                .toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(font: fontBold, fontSize: 8),
            tableWidth: pw.TableWidth.max,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = programmedMatches.isEmpty;

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: isEmpty ? Colors.grey : textGold,
        onPressed: isEmpty ? null : _generateAndPrintPdf,
        child: Icon(
          Icons.picture_as_pdf,
          color: isEmpty ? Colors.white70 : background,
        ),
      ),
      body: _buildBody(isEmpty),
    );
  }

  Widget _buildBody(bool isEmpty) {
    if (isLoading) {
      return Center(
        child: CustomLoader(text: 'Récupération de vos matches programmés'),
      );
    }

    if (isEmpty) {
      return Center(
        child: Text(
          "Vous n'avez aucune programmation",
          style: TextStyle(color: textGold, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedMatches.length,
      itemBuilder: (context, index) {
        final match = sortedMatches[index];
        return ProgrammedMatchCard(
          idMatch: match.id,
          leagueName: match.league.name,
          gameName: match.game.name,
          date: match.date,
          team1: match.team1,
          team2: match.team2,
          hypeScore: match.hypeScore,
          streamPlatform: match.streamPlatform,
          getIdMatch: _deleteProgramation,
        );
      },
    );
  }
}
