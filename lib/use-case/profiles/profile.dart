import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/use-case/profiles/favorites.component.dart';
import 'package:hall_e_mobile/use-case/profiles/informations.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/services/location_service.services.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/contact_mail.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  bool _isFavorites = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(accountProvider);
    final provider = ref.read(accountProvider.notifier);

    if (user.role != 'bar') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LocationService().getLocation(context, provider);
      });
    }
  }

  void _toggleTab() => setState(() => _isFavorites = !_isFavorites);

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: background,
        title: const Text('Supprimer le compte',
            style: TextStyle(color: textGold)),
        content: const Text(
          'Cette action est irréversible. Voulez-vous continuer ?',
          style: TextStyle(color: textGold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: textGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final apiUrl = dotenv.env['API_URL'];
    final user = ref.read(accountProvider);

    setState(() => _isDeleting = true);

    try {
      final response = await request(
        '$apiUrl/user/${user.id}',
        'DELETE',
        token: user.token,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw DioException(
          requestOptions: RequestOptions(path: '$apiUrl/user/${user.id}'),
          type: DioExceptionType.connectionTimeout,
          message: 'Timeout',
        ),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        showSuccessSnackBar(context, 'Votre compte a bien été supprimé');
        ref.read(accountProvider.notifier).logout();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.type == DioExceptionType.connectionTimeout
          ? 'Délai dépassé — vérifiez votre connexion'
          : e.response?.data?['message'] as String? ??
              'Erreur lors de la suppression';
      showErrorSnackBar(context, msg);
      await handleError(e, context);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(accountProvider);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double contentWidth = isTablet ? 500 : double.infinity;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              // Onglets Favoris / Informations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton(label: 'Vos favoris', isActive: _isFavorites),
                  _buildTabButton(
                      label: 'Vos informations', isActive: !_isFavorites),
                ],
              ),
              const SizedBox(height: 10),

              // Contenu de l'onglet
              _isFavorites
                  ? FavoritesComponent(profile: profile)
                  : InformationsComponent(profile: profile),
              const SizedBox(height: 10),

              // Actions du compte
              _buildActionButton(
                label: 'Se déconnecter',
                color: textGold,
                textColor: background,
                onPressed: () => ref.read(accountProvider.notifier).logout(),
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                label: 'Supprimer le compte',
                color: Colors.red,
                textColor: background,
                isLoading: _isDeleting,
                onPressed: _deleteAccount,
              ),

              // Contact
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: textGold),
                    children: [
                      const TextSpan(text: 'Un problème ? '),
                      TextSpan(
                        text: 'Contactez nous',
                        style: const TextStyle(
                          color: textGold,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchEmail(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({required String label, required bool isActive}) {
    return ElevatedButton(
      onPressed: _toggleTab,
      style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? textGold : background,
          side: BorderSide(color: isActive ? textGold : textGrey)),
      child: Text(
        label,
        style: TextStyle(color: isActive ? background : textGold),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: background),
                )
              : Text(label, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }
}
