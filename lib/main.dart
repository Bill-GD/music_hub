import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music_hub/app.dart';
import 'package:music_hub/data/services/backup_handler.dart';
import 'package:music_hub/data/services/database_handler.dart';
import 'package:music_hub/data/services/log_handler.dart';
import 'package:music_hub/ui/app/player/player_utils.dart';
import 'package:music_hub/utils/config.dart';
import 'package:music_hub/utils/globals/globals.dart';
import 'package:music_hub/utils/globals/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  Globals.storagePath = (await getExternalStorageDirectory())?.parent.path ?? '';

  Globals.logPath = '${Globals.storagePath}/files/log.txt';
  Globals.jsonPath = '${Globals.storagePath}/files/tracks.json';
  Globals.dbPath = '${Globals.storagePath}/database/database.db';
  // Globals.backupPath = '${Globals.storagePath}/music_hub_backup/';

  LogHandler.init();
  LogHandler.log('App version: ${Globals.appVersion}, isDev: $isDev');

  Globals.audioHandler = (await initAudioHandler()) as AudioPlayerHandler;
  await Config.loadConfig();
  await DatabaseHandler.init();
  BackupHandler.init();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  PlatformDispatcher.instance.onError = (e, s) {
    LogHandler.log(e.toString(), LogLevel.error);
    final curContext = navigatorKey.currentContext;
    if (curContext == null) return false;

    showPopupMessage(
      curContext,
      icon: Icon(
        Icons.error_rounded,
        color: Theme.of(curContext).colorScheme.error,
        size: 30,
      ),
      title: e.toString(),
      content: s.toString(),
      centerContent: false,
      horizontalPadding: 16,
    );
    return true;
  };

  runApp(MusicHubApp(navKey: navigatorKey));
}

