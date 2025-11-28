import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'package:music_hub/app.dart';
import 'package:music_hub/data/services/backup_service.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/github_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/lyric_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/home/home_view_model.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart' show Constants, Paths;
import 'package:music_hub/utils/extensions.dart' show DurationFromNumber;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Paths.init();

  GetIt.I.registerSingleton(
    Dio(BaseOptions(connectTimeout: 10.seconds, validateStatus: (_) => true)),
  );

  GetIt.I.registerSingleton(LogService(logPath: Paths.logPath));
  GetIt.I<LogService>().log(
    'App version: ${Constants.appVersion}, isDev: ${Constants.isDev}',
  );

  GetIt.I.registerSingleton(ConfigService());
  GetIt.I.registerSingleton(await DatabaseService.create(path: Paths.dbPath));
  GetIt.I.registerSingleton(SongService());
  GetIt.I.registerSingleton(BackupService());
  GetIt.I.registerSingleton(LyricService());
  GetIt.I.registerSingleton(GithubService());
  GetIt.I.registerSingleton(
    await (() async {
      final handler = await AudioService.init(
        builder: () => PlayerService(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.billgd.music_hub.channel.audio',
          androidNotificationChannelName: Constants.appName,
        ),
      );
      return handler;
    })(),
  );

  await GetIt.I<ConfigService>().loadConfig();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  PlatformDispatcher.instance.onError = (e, s) {
    GetIt.I<LogService>().log(e.toString(), .error);
    final curContext = navigatorKey.currentContext;
    if (curContext == null) return false;

    curContext.showPopupMessage(
      icon: Icon(
        Icons.error_rounded,
        color: curContext.theme.colorScheme.error,
        size: 30,
      ),
      title: e.toString(),
      content: s.toString(),
      centerContent: false,
    );
    return true;
  };

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeViewModel())],
      child: MusicHubApp(navKey: navigatorKey),
    ),
  );
}
