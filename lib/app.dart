import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/app/home/home_screen.dart';
import 'package:music_hub/ui/core/widgets/errored_widget.dart';
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

class MusicHubApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;

  const MusicHubApp({super.key, required this.navKey});

  @override
  State<MusicHubApp> createState() => _MusicHubAppState();
}

class _MusicHubAppState extends State<MusicHubApp> {
  late final StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((newResults) {
      checkInternetConnection(newResults).then((val) {
        Globals.isInternetConnected.value = val;
      });
    });
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      defaultThemeId:
          '${SchedulerBinding.instance.platformDispatcher.platformBrightness.name}_theme',
      themes: [
        AppTheme(
          id: 'light_theme',
          description: 'Light theme',
          data: ThemeData(
            useMaterial3: true,
            fontFamily: 'Nunito',
            brightness: .light,
            sliderTheme: const SliderThemeData(
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            colorScheme: .fromSeed(seedColor: Colors.white, brightness: .light),
          ),
        ),
        AppTheme(
          id: 'dark_theme',
          description: 'Dark theme',
          data: ThemeData(
            useMaterial3: true,
            fontFamily: 'Nunito',
            brightness: .dark,
            sliderTheme: const SliderThemeData(
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            colorScheme: .fromSeed(seedColor: Colors.grey, brightness: .dark),
          ),
        ),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (context) {
            return MaterialApp(
              navigatorKey: widget.navKey,
              builder: (context, child) {
                ErrorWidget.builder = (errorDetails) {
                  GetIt.I<LogService>().log(errorDetails.exception.toString(), .error);
                  return ErroredWidget(e: errorDetails);
                };
                return child!;
              },
              theme: ThemeProvider.themeOf(context).data,
              title: 'Music Hub',
              home: HomeScreen(viewModel: context.read()),
            );
          },
        ),
      ),
    );
  }
}
