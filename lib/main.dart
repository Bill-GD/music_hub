import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music_hub/app.dart';
import 'package:music_hub/data/services/backup_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/app/player/player_utils.dart';
import 'package:music_hub/utils/config.dart';
import 'package:music_hub/utils/globals/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  Globals.storagePath = (await getExternalStorageDirectory())?.parent.path ?? '';

  Globals.logPath = '${Globals.storagePath}/files/log.txt';
  Globals.jsonPath = '${Globals.storagePath}/files/tracks.json';
  Globals.dbPath = '${Globals.storagePath}/database/database.db';
  // Globals.backupPath = '${Globals.storagePath}/music_hub_backup/';

  LogService.init();
  LogService.log('App version: ${Globals.appVersion}, isDev: $isDev');

  Globals.audioHandler = (await initAudioHandler()) as AudioPlayerHandler;
  await ConfigService.loadConfig();
  await DatabaseService.init();
  BackupService.init();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  PlatformDispatcher.instance.onError = (e, s) {
    LogService.log(e.toString(), LogLevel.error);
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

  runApp(MusicHubApp(navKey: navigatorKey));
}
