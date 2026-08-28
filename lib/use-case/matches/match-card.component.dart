import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hall_e_mobile/models/bar-minimal-informations.model.dart';
import 'package:hall_e_mobile/models/game.model.dart';
import 'package:hall_e_mobile/models/league.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/use-case/matches/match_details_page.component.dart';
import 'package:hall_e_mobile/utils/format-stream-url.utils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchCard extends ConsumerStatefulWidget {
  const MatchCard({
    super.key,
    required this.role,
    required this.hypeScore,
    required this.idMatch,
    required this.streamPlatform,
    required this.team1,
    required this.team2,
    required this.numberOfGame,
    required this.programmed,
    required this.league,
    required this.game,
    required this.date,
    required this.getIdMatch,
  });

  final String role;
  final String idMatch;
  final String numberOfGame;
  final List<String> streamPlatform;
  final int hypeScore;
  final Team team1;
  final Team team2;
  final List<BarMinimalInformations>? programmed;
  final League league;
  final Game game;
  final String date;
  final Function getIdMatch;

  @override
  ConsumerState<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends ConsumerState<MatchCard> {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  bool? _programmedOverride;

  // Retour visuel d'appui : la carte se rétracte légèrement quand on la presse.
  bool _pressed = false;

  String _formatTime(String date) {
    return DateFormat("HH'h'mm").format(DateTime.parse(date).toLocal());
  }

  bool _isMatchProgrammedWithBar(List<BarMinimalInformations> programmed) {
    final User user = ref.watch(accountProvider);
    return programmed.any((bar) => bar.name == user.informations.name);
  }

  void _openDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchDetailsPage(
          date: widget.date,
          game: widget.game,
          numberOfGame: widget.numberOfGame,
          league: widget.league,
          team1: widget.team1,
          team2: widget.team2,
          barList: widget.programmed ?? [],
        ),
      ),
    );
  }

  Future<void> _lunchStreamUrl(String url) async {
    Uri parseUrl = Uri.parse(url);
    try {
      if (await canLaunchUrl(parseUrl)) {
        await launchUrl(parseUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Impossible d'ouvrir : $url");
      }
    } catch (e) {
      debugPrint("Erreur lors de l'ouverture du stream : $e");
    }
  }

  // ---------------------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------------------

  /// Logo d'équipe avec placeholder shimmer, cache et fallback.
  Widget _buildTeamLogo(String logoUrl) {
    const fallback = Icon(FontAwesomeIcons.notdef, color: textGold, size: 45);

    if (logoUrl.isEmpty) return fallback;

    return CachedNetworkImage(
      imageUrl: logoUrl,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0',
        'Referer': 'https://cdn-api.pandascore.co/',
      },
      // Affiché immédiatement pendant le téléchargement
      placeholder: (_, __) => const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textGold,
          ),
        ),
      ),
      // Fallback si l'URL est inaccessible
      errorWidget: (_, __, ___) => fallback,
    );
  }

  /// Ligne logo + nom d'une équipe.
  Widget _buildTeamRow(Team team) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 40),
        CircleAvatar(
            radius: 35,
            backgroundColor: textWhite,
            child: _buildTeamLogo(team.logoUrl)),
        const SizedBox(width: 55),
        Expanded(
          child: Text(
            team.name,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              color: textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Bandeau supérieur : nom du jeu + heure + chevron (indice de clic).
  Widget _buildGameHeader(String hours) {
    return Container(
      decoration: const BoxDecoration(color: bgCard),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.game.name.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                color: textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: btnBg50Gold,
              border: Border.all(color: borderGold50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(hours, style: const TextStyle(color: textGold)),
          ),
          // Indice visuel : signale que la carte est cliquable.
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: textGold, size: 22),
        ],
      ),
    );
  }

  /// Bandeau ligue + bouton/texte de programmation.
  Widget _buildLeagueRow(bool matchIsProgrammed) {
    // si on a appuyé localement, on prend cette valeur en priorité
    final isProgrammed = _programmedOverride ?? matchIsProgrammed;

    return Container(
      decoration: const BoxDecoration(color: bgCard),
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.league.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                color: textGold,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.role == 'bar')
            IconButton(
              onPressed: isProgrammed
                  ? null
                  : () {
                      widget.getIdMatch(widget.idMatch);
                      setState(() => _programmedOverride = true);
                    },
              // couleur quand actif
              color: textGold,
              // couleur quand désactivé (sinon gris invisible)
              disabledColor: textGold,
              // Aligné au bord droit comme les flammes et le chevron :
              // on retire le padding interne mais on garde une zone de tap.
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: isProgrammed
                  ? Text(
                      "Match programmé",
                      style: TextStyle(color: textGold),
                    )
                  : const Icon(Icons.add_circle, size: 24),
            )
          else if (widget.programmed != null)
            const Text(
              'Match programmé',
              style: TextStyle(
                color: textGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  /// Bandeau plateformes de streaming + hype score.
  Widget _buildStreamRow() {
    final hasStream = widget.streamPlatform.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(color: bgCard),
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasStream)
            ...widget.streamPlatform.map((String url) => Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: InkWell(
                    onTap: () => _lunchStreamUrl(url),
                    child: Text(getStreamName(url),
                        style: const TextStyle(
                            color: textGrey,
                            decoration: TextDecoration.underline,
                            decorationColor: textGrey)),
                  ),
                ))
          else
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 10),
              child: Text(
                'Aucune information sur la diffusion',
                style: TextStyle(color: textGold),
              ),
            ),
          Row(
            children: List.generate(
              widget.hypeScore.clamp(0, 3),
              (_) =>
                  const Icon(FontAwesomeIcons.fire, color: textGold, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final hours = _formatTime(widget.date);
    final matchIsProgrammed = widget.programmed != null
        ? _isMatchProgrammedWithBar(widget.programmed!)
        : false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        // onTapUp ouvre le détail. Si un bouton interne (ex. "programmer"
        // pour les bars) capte le tap, ce geste est annulé (onTapCancel),
        // donc pas de navigation involontaire.
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _openDetails();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: textGold, width: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: const Color.fromRGBO(0, 0, 0, 2),
              color: bgCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGameHeader(hours),
                  _buildLeagueRow(matchIsProgrammed),
                  _buildStreamRow(),
                  const SizedBox(height: 12),
                  Divider(thickness: 0.0, color: textGold),
                  // Équipes
                  Container(
                    alignment: Alignment.center,
                    color: bgCard,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildTeamRow(widget.team1),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      textGold.withAlpha(0), // transparent
                                      textGold, // plein près du VS
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "VS",
                                style: TextStyle(color: textGold, fontSize: 25),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      textGold, // plein près du VS
                                      textGold.withAlpha(0), // transparent
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildTeamRow(widget.team2),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
