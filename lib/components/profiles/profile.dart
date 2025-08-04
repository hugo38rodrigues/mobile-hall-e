import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/profiles/favorites.component.dart';
import 'package:hall_e_mobile/components/profiles/informations.component.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/services/location-service.services.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/contact-mail.dart';

class Profile extends ConsumerStatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  bool isFavorites = true;
  @override
  void initState() {
    super.initState();
    User user = ref.read(accountProvider);
    AccountNotifier provider = ref.read(accountProvider.notifier);
    LocationService location = LocationService();
    if (user.role != 'bar') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        location.getLocation(context, provider);
      });
    }
  }

  void handleChangeDisplayProfile() => {
        setState(() {
          isFavorites = !isFavorites;
        })
      };

  @override
  Widget build(BuildContext context) {
    User profile = ref.watch(accountProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: handleChangeDisplayProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFavorites ? secondaryColor : primaryColor),
                child: Text(
                  "Vos favoris",
                  style: TextStyle(
                      color: isFavorites ? primaryColor : secondaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: handleChangeDisplayProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFavorites ? primaryColor : secondaryColor),
                child: Text(
                  "Vos informations",
                  style: TextStyle(
                      color: isFavorites ? secondaryColor : primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          isFavorites
              ? FavoritesComponent(profile: profile)
              : InformationsComponent(profile: profile),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: secondaryColor),
                onPressed: () async {
                  await ref.watch(accountProvider.notifier).logout();
                },
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 20),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: secondaryColor),
                children: [
                  TextSpan(text: "Un problème ? "),
                  TextSpan(
                    text: "Contactez nous",
                    style: TextStyle(
                        color: secondaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()..onTap = launchEmail,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
