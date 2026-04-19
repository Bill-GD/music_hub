import 'package:flutter/material.dart';

import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/utils/utils.dart';

class SettingsViewModel extends ChangeNotifier {
  final _configService = get<ConfigService>(), _playerService = get<PlayerService>();

  late bool _backupOnLaunch = _configService.backupOnLaunch;
  late bool _enableSongFiltering = _configService.enableSongFiltering;
  late int _lengthLimitSeconds = _configService.lengthLimitMilliseconds ~/ 1e3;
  late bool _autoPlayNewSong = _configService.autoPlayNewSong;
  late int _delayMilliseconds = _configService.delayMilliseconds;
  late bool _appendLyric = _configService.appendLyric;
  late double _volume = _configService.volume;
  late int _backupCount = _configService.backupCount;

  // getters
  bool get backupOnLaunch => _backupOnLaunch;

  bool get enableSongFiltering => _enableSongFiltering;

  int get lengthLimitSeconds => _lengthLimitSeconds;

  bool get autoPlayNewSong => _autoPlayNewSong;

  int get delayMilliseconds => _delayMilliseconds;

  bool get appendLyric => _appendLyric;

  double get volume => _volume;

  int get backupCount => _backupCount;

  set backupOnLaunch(bool val) {
    _backupOnLaunch = val;
    notifyListeners();
  }

  set enableSongFiltering(bool val) {
    _enableSongFiltering = val;
    notifyListeners();
  }

  set lengthLimitSeconds(int val) {
    if (!_enableSongFiltering) return;
    _lengthLimitSeconds = val;
    notifyListeners();
  }

  set autoPlayNewSong(bool val) {
    _autoPlayNewSong = val;
    notifyListeners();
  }

  set delayMilliseconds(int val) {
    _delayMilliseconds = val;
    notifyListeners();
  }

  set appendLyric(bool val) {
    _appendLyric = val;
    notifyListeners();
  }

  set volume(double val) {
    _volume = val;
    notifyListeners();
  }

  set backupCount(int val) {
    _backupCount = val;
    notifyListeners();
  }

  bool get hasChanges =>
      _backupOnLaunch != _configService.backupOnLaunch ||
      _enableSongFiltering != _configService.enableSongFiltering ||
      _lengthLimitSeconds != _configService.lengthLimitMilliseconds ~/ 1e3 ||
      _autoPlayNewSong != _configService.autoPlayNewSong ||
      _delayMilliseconds != _configService.delayMilliseconds ||
      _appendLyric != _configService.appendLyric ||
      _volume != _configService.volume ||
      _backupCount != _configService.backupCount;

  List<String> getChanges() {
    final changes = <String>[];

    if (_enableSongFiltering != _configService.enableSongFiltering) {
      changes.add('${_enableSongFiltering ? 'Enable' : 'Disable'} song filtering');
    }
    if (_enableSongFiltering &&
        _lengthLimitSeconds != _configService.lengthLimitMilliseconds ~/ 1e3) {
      changes.add('Filter file shorter than: $_lengthLimitSeconds s');
    }
    if (_autoPlayNewSong != _configService.autoPlayNewSong) {
      changes.add('${_autoPlayNewSong ? 'Enable' : 'Disable'} auto play');
    }
    if (_appendLyric != _configService.appendLyric) {
      changes.add('${_appendLyric ? 'Enable' : 'Disable'} append lyric');
    }
    if (_backupOnLaunch != _configService.backupOnLaunch) {
      changes.add('${_backupOnLaunch ? 'Enable' : 'Disable'} auto backup');
    }
    if (_delayMilliseconds != _configService.delayMilliseconds) {
      changes.add('Delay between songs: $_delayMilliseconds ms');
    }
    if (_volume != _configService.volume) {
      changes.add('Volume: x$_volume');
    }
    if (_backupCount != _configService.backupCount) {
      changes.add('Backup count: $_backupCount');
    }

    return changes;
  }

  Future<void> updateConfig() async {
    _configService.backupOnLaunch = _backupOnLaunch;
    _configService.enableSongFiltering = _enableSongFiltering;
    _configService.lengthLimitMilliseconds = _lengthLimitSeconds * 1000;
    _configService.autoPlayNewSong = _autoPlayNewSong;
    _configService.delayMilliseconds = _delayMilliseconds;
    _configService.appendLyric = _appendLyric;
    _configService.volume = _volume;
    _playerService.setVolume(_configService.volume);
    _configService.backupCount = _backupCount;
    await _configService.saveConfig();
    notifyListeners();
  }
}
