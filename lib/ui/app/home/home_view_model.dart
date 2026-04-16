import 'package:flutter/foundation.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:music_hub/data/services/backup_service.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/github_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/playlist_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

class HomeViewModel extends ChangeNotifier {
  final playerService = get<PlayerService>(),
      playlistService = get<PlaylistService>(),
      songService = get<SongService>(),
      _logService = get<LogService>(),
      _configService = get<ConfigService>(),
      _backupService = get<BackupService>(),
      _githubService = get<GithubService>();

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
    await playlistService.recoverSavedPlaylist();
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
