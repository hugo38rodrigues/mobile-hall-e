import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/programmation-match.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BarCard extends ConsumerWidget {
  final BarUser bar;
  const BarCard({required this.bar, super.key});

  static final _isIos = Platform.isIOS;

  static const _gameLogos = {
    'Valorant': 'assets/gameLogos/valorant.png',
    'League of legends': 'assets/gameLogos/lol.png',
    'Cs go': 'assets/gameLogos/cs.png',
  };

  // ──────────────────── FORMATAGE ────────────────────

  String _formatDate(String date) {
    final dt = DateTime.parse(date).toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String _formatHour(String date) {
    final dt = DateTime.parse(date).toLocal();
    final mins = dt.minute.toString().padLeft(2, '0');
    return '${dt.hour}H$mins';
  }

  String _getGameLogo(String gameName) =>
      _gameLogos[gameName] ?? 'assets/gameLogos/lol.png';

  List<ProgrammationMatch> _sortedMatches(List<ProgrammationMatch> matches) {
    return List.from(matches)
      ..sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
  }

  // ──────────────────── NAVIGATION ────────────────────

  Future<void> _openMaps(String address, double lat, double lng) async {
    final google = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$lat,$lng&destination=${Uri.encodeComponent(address)}',
    );
    final apple = Uri.parse(
      'maps://?saddr=$lat,$lng&daddr=${Uri.encodeComponent(address)}',
    );

    try {
      final uri = _isIos && await canLaunchUrl(apple) ? apple : google;
      await launchUrl(uri);
    } catch (e) {
      debugPrint("Erreur lors de l'ouverture de Maps: $e");
    }
  }

  // ──────────────────── BUILD ────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountProvider);
    final informations = bar.informations;
    final matches = bar.programations ?? [];

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: textGold, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: bgCard,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(informations),
            _buildMatchList(matches),
            const SizedBox(height: 2),
            _buildLocationButton(informations, profile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Informations informations) {
    return Container(
      decoration: const BoxDecoration(color: bgCard),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                informations.name!,
                style: const TextStyle(
                  fontSize: 15,
                  color: textGold,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: textGold,
            thickness: 0.5,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(List<ProgrammationMatch> matches) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: _sortedMatches(matches)
            .map((prog) => _buildMatchRow(prog))
            .toList(),
      ),
    );
  }

  Widget _buildMatchRow(ProgrammationMatch prog) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // DATE — élargie
          SizedBox(
            width: 60,
            child: Text(
              _formatDate(prog.date),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                color: textGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // LOGO
          SizedBox(
            width: 36,
            child: Center(
              child: Image(
                width: 28,
                height: 28,
                color: textGold,
                image: AssetImage(_getGameLogo(prog.game.name)),
              ),
            ),
          ),

          // ÉQUIPES — team1 / VS / team2
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    prog.team1.acronym,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 36,
                  child: Text(
                    'VS',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textGold),
                  ),
                ),
                Expanded(
                  child: Text(
                    prog.team2.acronym,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // HEURE — élargie
          SizedBox(
            width: 64,
            child: Text(
              _formatHour(prog.date),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                color: textGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton(Informations informations, User profile) {
    final isActivated = profile.userLocation.isActivated;

    return Center(
      child: SizedBox(
        width: isActivated ? 175 : 210,
        height: 30,
        child: ElevatedButton(
          onPressed: isActivated
              ? () => _openMaps(
                    informations.address!,
                    profile.userLocation.latitude,
                    profile.userLocation.longitude,
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgCard,
            side: BorderSide(color: textGrey),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isActivated ? "Trouver le bar" : "Activer la localisation",
                style: const TextStyle(
                  color: textGold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isActivated) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_circle_right_outlined,
                  size: 24,
                  color: textGold,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
