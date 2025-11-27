import 'package:flutter/cupertino.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:music_hub/data/services/backup_service.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/constants.dart' show Constants;
import 'package:music_hub/utils/extensions.dart' show WhereOrNull;
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart' show checkInternetConnection, getAllTags;

class HomeViewModel extends ChangeNotifier {
  final PlayerService playerService;
  final SongService songService;
  final LogService _logService;
  final ConfigService _configService;
  final BackupService _backupService;

  bool loading = true;

  HomeViewModel({
    required this.playerService,
    required this.songService,
    required LogService logService,
    required ConfigService configService,
    required BackupService backupService,
  }) : _logService = logService,
       _configService = configService,
       _backupService = backupService {
    playerService.player.processingStateStream.listen((state) {
      notifyListeners();
    });
    playerService.player.positionStream.listen((current) {
      notifyListeners();
    });
  }

  Future<PermissionStatus> checkStoragePermission() async {
    PermissionStatus storagePermissionStatus =
        await Permission.manageExternalStorage.status;
    if (!storagePermissionStatus.isGranted) {
      _logService.log('Storage permission not granted, redirecting to request page');

      if (_configService.backupOnLaunch) {
        _configService.backupOnLaunch = false;
        _configService.saveConfig();
      }
    }
    return storagePermissionStatus;
  }

  Future<void> loadSongs() async {
    _logService.log('Storage permission is granted');
    await songService.updateMusicData();
    songService.sortAllSongs();

    if (_configService.backupOnLaunch) {
      _backupService.backupData();
    }
    await playerService.recoverSavedPlaylist();
    Globals.showMinimizedPlayer =
        songService.allSongs.firstWhereOrNull(
          (e) => e.id == songService.currentSongID,
        ) !=
        null;

    _logService.log('App is ready');
    loading = false;
    notifyListeners();
  }

  Future<(bool, String?)> checkNewVersion() async {
    final hasInternet = await checkInternetConnection();
    if (!hasInternet) return (false, null);
    final tags = (await getAllTags()).map((e) => e.$1).toList();
    if (tags.isEmpty || 'v${Constants.appVersion}' == tags.last) return (false, null);
    return (true, tags.last);
  }
}
