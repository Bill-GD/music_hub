import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:theme_provider/theme_provider.dart';

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
                ErrorWidget.builder = (errorDetails) => ErroredWidget(e: errorDetails);
                // updateDebugOverlay = () {
                //   // logHandler.info('Updating debug overlay');
                //   if (context.mounted) setState(() {});
                // };
                // return Stack(
                //   children: [
                //     child!,
                //     showDebugInfo ? debugOverlay() : const SizedBox(),
                //   ],
                // );
                return child!;
              },
              theme: ThemeProvider.themeOf(context).data,
              title: 'Music Hub',
              home: const MainScreen(),
              // setup route to use Navigator.pushNamed to wait page navigation (pause previous page until return)
              // routes: {
              //   '/music_downloader': (context) => const MusicDownloader(),
              // },
            );
          },
        ),
      ),
    );
  }
}
