import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

class AppViewModel extends ChangeNotifier {
  final _logService = get<LogService>();

  late final StreamSubscription<List<ConnectivityResult>> connectionSubscription;

  AppViewModel() {
    _init();
  }

  void _init() {
    connectionSubscription = Connectivity().onConnectivityChanged.listen((
      newResults,
    ) async {
      Globals.isInternetConnected.value = !newResults.contains(ConnectivityResult.none);
      _logService.log(
        'Internet connectivity: ${Globals.isInternetConnected.value ? 'on' : 'off'}',
      );
    });
  }

  @override
  void dispose() {
    connectionSubscription.cancel();
    super.dispose();
  }
}
