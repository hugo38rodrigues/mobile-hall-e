import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hall_e_mobile/models/team.model.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/date.dart';
import 'package:hall_e_mobile/utils/format-stream-url.utils.dart';

class ProgrammedMatchCard extends ConsumerStatefulWidget {
  final String idMatch;
  final String leagueName;
  final String gameName;
  final List<String> streamPlatform;
  final int hypeScore;
  final String date;
  final Team team1;
  final Team team2;
  final Function(String idMatch) getIdMatch;

  const ProgrammedMatchCard({
    super.key,
    required this.date,
    required this.gameName,
    required this.getIdMatch,
    required this.idMatch,
    required this.leagueName,
    required this.hypeScore,
    required this.streamPlatform,
    required this.team1,
    required this.team2,
  });

  @override
  ConsumerState<ProgrammedMatchCard> createState() =>
      _ProgrammedMatchCardState();
}

class _ProgrammedMatchCardState extends ConsumerState<ProgrammedMatchCard> {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Logo d'équipe avec placeholder, cache et fallback.
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
      placeholder: (_, __) => const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: textGold),
        ),
      ),
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
          child: _buildTeamLogo(team.logoUrl),
        ),
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

  /// Bandeau supérieur : nom du jeu + heure.
  Widget _buildGameHeader(String hours) {
    return Container(
      decoration: const BoxDecoration(color: bgCard),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.gameName.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              color: textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: btnBg50Gold,
              border: Border.all(color: borderGold50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(hours, style: const TextStyle(color: textGold)),
          ),
        ],
      ),
    );
  }

  /// Bandeau ligue + bouton de déprogrammation (croix).
  Widget _buildLeagueRow() {
    return Container(
      decoration: const BoxDecoration(color: bgCard),
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.leagueName.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                color: textGold,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => widget.getIdMatch(widget.idMatch),
            color: textGold,
            icon: const Icon(Icons.close),
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
      padding: const EdgeInsets.only(right: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasStream)
            ...widget.streamPlatform.map(
              (url) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 10),
                child: Text(getStreamName(url),
                    style: const TextStyle(color: textGold)),
              ),
            )
          else
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 10),
              child:
                  Text('Match pas diffusé', style: TextStyle(color: textGold)),
            ),
          Row(
            children: List.generate(
              widget.hypeScore.clamp(0, 3),
              (_) => const Icon(FontAwesomeIcons.fire, color: textGold),
            ),
          ),
        ],
      ),
    );
  }

  /// Séparateur "VS" avec lignes en dégradé.
  Widget _buildVsDivider() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [textGold.withAlpha(0), textGold],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text("VS", style: TextStyle(color: textGold, fontSize: 25)),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [textGold, textGold.withAlpha(0)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final hours = formatDate(widget.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(1),
        child: InkWell(
          borderRadius: BorderRadius.circular(1),
          splashColor: textGold,
          highlightColor: const Color.fromRGBO(255, 255, 255, 0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: textGold, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: const Color.fromRGBO(0, 0, 0, 0.2),
              color: bgCard,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGameHeader(hours),
                    _buildLeagueRow(),
                    _buildStreamRow(),
                    const SizedBox(height: 12),
                    Divider(thickness: 0.3, color: textGold),
                    Container(
                      alignment: Alignment.center,
                      color: bgCard,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildTeamRow(widget.team1),
                          _buildVsDivider(),
                          _buildTeamRow(widget.team2),
                          const SizedBox(height: 12),
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
