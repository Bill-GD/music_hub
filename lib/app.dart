import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:get_it/get_it.dart';
import 'package:theme_provider/theme_provider.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/app/main_screen/main_screen.dart';
import 'package:music_hub/ui/core/widgets/errored_widget.dart';

class MusicHubApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;

  const MusicHubApp({super.key, required this.navKey});

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
            brightness: Brightness.light,
            sliderTheme: const SliderThemeData(
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.light,
            ),
          ),
        ),
        AppTheme(
          id: 'dark_theme',
          description: 'Dark theme',
          data: ThemeData(
            useMaterial3: true,
            fontFamily: 'Nunito',
            brightness: Brightness.dark,
            sliderTheme: const SliderThemeData(
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.grey,
              brightness: Brightness.dark,
            ),
          ),
        ),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (context) {
            return MaterialApp(
              navigatorKey: navKey,
              builder: (context, child) {
                ErrorWidget.builder = (errorDetails) {
                  GetIt.I<LogService>().log(errorDetails.exception.toString(), .error);
                  return ErroredWidget(e: errorDetails);
                };
                return child!;
              },
              theme: ThemeProvider.themeOf(context).data,
              title: 'Music Hub',
              home: const MainScreen(),
            );
          },
        ),
      ),
    );
  }
}
