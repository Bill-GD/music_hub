import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:music_hub/data/services/backup_service.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/github_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/constants.dart' show Constants;
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

class HomeViewModel extends ChangeNotifier {
  final PlayerService playerService = GetIt.I();
  final SongService songService = GetIt.I();
  final LogService _logService = GetIt.I();
  final ConfigService _configService = GetIt.I();
  final BackupService _backupService = GetIt.I();
  final GithubService _githubService = GetIt.I();

  bool loading = true;

  HomeViewModel() {
    playerService.player.processingStateStream.listen((state) {
      notifyListeners();
    });
    playerService.player.positionStream.listen((current) {
      notifyListeners();
    });
  }

  Future<PermissionStatus> checkStoragePermission() async {
    final storagePermissionStatus = await Permission.manageExternalStorage.status;

    if (storagePermissionStatus.isGranted) {
      _logService.log('Storage permission is granted');
    } else {
      _logService.log('Storage permission not granted, redirecting to request page');
      if (_configService.backupOnLaunch) {
        _configService.backupOnLaunch = false;
        _configService.saveConfig();
      }
    }
    return storagePermissionStatus;
  }

  Future<void> load() async {
    await loadData();
    songService.sortAllSongs();

    if (_configService.backupOnLaunch) {
      _backupService.backupData();
    }
    await playerService.recoverSavedPlaylist();
    Globals.showMinimizedPlayer.value = songService.hasSong(songService.currentSongID);

    _logService.log('App is ready');
    loading = false;
    notifyListeners();
  }

  Future<(bool, String?)> checkNewVersion() async {
    if (!Globals.isInternetConnected.value) return (false, null);
    final tags = (await _githubService.getAllTags()).map((e) => e.$1).toList();
    if (tags.isEmpty || 'v${Constants.appVersion}' == tags.last) return (false, null);
    return (true, tags.last);
  }
}
