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
  final _playerService = get<PlayerService>(),
      _playlistService = get<PlaylistService>(),
      _songService = get<SongService>(),
      _logService = get<LogService>(),
      _configService = get<ConfigService>(),
      _backupService = get<BackupService>(),
      _githubService = get<GithubService>();

  bool loading = true;

  HomeViewModel() {
    _playerService.player.processingStateStream.listen((state) {
      notifyListeners();
    });
    _playerService.player.positionStream.listen((current) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _playerService.player.dispose();
    super.dispose();
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

  Future<void> load({void Function(String text)? updateToast}) async {
    await loadData(updateToast: updateToast);
    _songService.sortAllSongs();

    if (_configService.backupOnLaunch) {
      _backupService.backupData();
    }
    updateToast?.call('Recovering saved playlist');
    await _playlistService.recoverSavedPlaylist();
    Globals.showMinimizedPlayer.value = _songService.hasSong(_songService.currentSongID);

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
