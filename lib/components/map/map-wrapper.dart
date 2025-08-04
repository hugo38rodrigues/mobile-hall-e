import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/map/client-map.dart';
import 'package:hall_e_mobile/models/bar-minimal-informations.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class MapWrapper extends ConsumerStatefulWidget {
  final List<BarMinimalInformations> addressList;
  const MapWrapper({required this.addressList});

  @override
  ConsumerState<MapWrapper> createState() => _MapWrapperState();
}

class _MapWrapperState extends ConsumerState<MapWrapper> {
  bool isIos = Platform.isIOS;
  List barNameFavorites = [];
  late User profile;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    getFavoritesBarName();
  }

  getFavoritesBarName() {
    User profile = ref.read(accountProvider);
    if (profile.role != 'guest') {
      setState(() {
        barNameFavorites = profile.favorites!.barName;
        profile = profile;
        isConnected = true;
      });
    }
  }

  handleStateBarNameFavorites(idBar, barName) async {
    bool barNameIsPresent = barNameFavorites.any((bar) => bar == barName);
    barNameIsPresent
        ? await deletedFavoriteBarName(idBar)
        : await addFavoriteBarName(idBar);
  }

  addFavoriteBarName(idBar) async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    try {
      Response response = await dio
          .post('$apiUrl/favoris',
              data: {"idUser": profile.id, "idBar": idBar},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer ${profile.token}"
                },
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/favoris'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        ref
            .read(accountProvider.notifier)
            .updateAccount({'favorites': response.data});

        getFavoritesBarName();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  deletedFavoriteBarName(String idBar) async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    User profile = ref.read(accountProvider);

    try {
      Response response = await dio
          .delete('$apiUrl/favoris',
              data: {"idUser": profile.id, "idBar": idBar},
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
            requestOptions: RequestOptions(path: '$apiUrl/favoris'),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        ref
            .read(accountProvider.notifier)
            .updateAccount({'favorites': response.data});
        getFavoritesBarName();
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User profile = ref.watch(accountProvider);
    bool isNotBar = profile.role != "bar";

    return isNotBar
        ? ClientMap(
            barNameFavorites: barNameFavorites,
            handleStateBarNameFavorites: handleStateBarNameFavorites,
            addressList: widget.addressList,
          )
        : SizedBox();
  }
}
