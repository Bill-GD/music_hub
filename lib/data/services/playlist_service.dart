import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

class PlaylistService {
  final _logService = get<LogService>(),
      _configService = get<ConfigService>(),
      _playerService = get<PlayerService>(),
      _songService = get<SongService>(),
      _databaseService = get<DatabaseService>();

  /// Only keep track of IDs
  final List<int> _playlist = [];
  String? playlistName;
  AudioServiceShuffleMode _shuffle = .none;
  AudioServiceRepeatMode _repeat = .none;

  // Skip cooldown
  bool _skipping = false;

  /// Only keep track of IDs
  List<int> get playlist => List.from(_playlist);

  bool get isEmpty => _playlist.isEmpty;

  int get songCount => _playlist.length;

  String get playlistDisplayName =>
      '$playlistName ($songCount song${songCount > 1 ? 's' : ''})';

  bool get isShuffled => _shuffle == .all;

  AudioServiceRepeatMode get repeatMode => _repeat;

  Future<void> registerPlaylist(
    String name,
    List<int> list,
    int beginSongID, {
    bool saveList = true,
    bool shouldShuffle = true,
  }) async {
    _playlist.clear();
    _playlist.addAll(list);

    if (shouldShuffle && _shuffle == .all) {
      _shufflePlaylist(beginSongID: beginSongID, saveList: false);
    }

    int songCount = _playlist.length;
    playlistName = name;
    if (saveList) savePlaylist(beginSongID);
    _logService.log('Registered playlist: $playlistName ($songCount songs)');
  }

  void nextSong({bool shouldDelay = false}) async {
    if (_skipping) return;

    _logService.log('Skipping to next song');
    _skipping = true;

    if (_playlist.isEmpty) {
      _playerService.pause();
      return _logService.log('Playlist is empty, this should not be the case', .error);
    }

    if (_playlist.length == 1) {
      return _logService.log('Playlist only has one song, skipping action');
    }

    int currentIndex = _playlist.indexWhere((e) => e == _songService.currentSongID);

    if (currentIndex < 0) {
      _playerService.pause();
      return _logService.log(
        "Can't find song in playlist, this should not be the case",
        .error,
      );
    }

    if (shouldDelay && _configService.delayMilliseconds > 0) {
      await Future.delayed(
        _configService.delayMilliseconds.ms,
        () => _logService.log('Delayed for ${_configService.delayMilliseconds}ms'),
      );
    }

    if (currentIndex == _playlist.length - 1) {
      switch (_repeat) {
        case AudioServiceRepeatMode.all:
          _logService.log('Repeat all');
          if (isShuffled) _shufflePlaylist(currentToStart: false);
          await _playerService.setPlayerSong(_playlist[0]);
          await updateSavedPlaylist(currentIndex, 0);
          break;
        case AudioServiceRepeatMode.none:
          if (_playerService.player.processingState == ProcessingState.completed) {
            _logService.log('Repeat none');
            _playerService.pause();
          }
          break;
        default:
          await _playerService.setPlayerSong(_playlist[0]);
          await updateSavedPlaylist(currentIndex, 0);
          break;
      }
    } else {
      await _playerService.setPlayerSong(_playlist[currentIndex + 1]);
      await updateSavedPlaylist(_playlist[currentIndex], _playlist[currentIndex + 1]);
    }
    _skipping = false;
  }

  void prevSong() async {
    if (_skipping) return;

    _logService.log('Skipping to previous song');
    _skipping = true;

    if (_playlist.isEmpty) {
      _playerService.pause();
      return _logService.log('Playlist is empty, this should not be the case', .error);
    }

    if (_playlist.length == 1) {
      return _logService.log('Playlist only contains one song, skipping action');
    }

    int currentIndex = _playlist.indexWhere((e) => e == _songService.currentSongID);

    if (currentIndex < 0) {
      _playerService.pause();
      return _logService.log('Current ID is < 0, this should not be the case', .error);
    }

    final newIndex = (currentIndex == 0 ? _playlist.length : currentIndex) - 1;

    await updateSavedPlaylist(_songService.currentSongID, _playlist[newIndex]);
    await _playerService.setPlayerSong(_playlist[newIndex]);

    _skipping = false;
  }

  void savePlaylist(int currentID) {
    _databaseService.db.delete(TableNames.playlistTable).then((_) {
      _logService.log('Saving playlist ($playlistName): $playlist, current: $currentID');

      final data = _playlist.map(
        (e) => <String, Object?>{
          'list_name': playlistName!.trim(),
          'song_id': e,
          'is_current': e == currentID ? 1 : 0,
        },
      );

      for (final e in data) {
        _databaseService.db.insert(TableNames.playlistTable, e);
      }
    });
  }

  Future<void> updateSavedPlaylist(int oldID, int newID) async {
    if (playlistName != playlistName) return savePlaylist(newID);

    _logService.log('Update current ID of saved: $oldID -> $newID');

    _databaseService.db.update(
      TableNames.playlistTable,
      {'is_current': 0},
      where: 'song_id = ?',
      whereArgs: [oldID],
    );
    _databaseService.db.update(
      TableNames.playlistTable,
      {'is_current': 1},
      where: 'song_id = ?',
      whereArgs: [newID],
    );
  }

  Future<void> recoverSavedPlaylist() async {
    final res = await _databaseService.db.query(TableNames.playlistTable, orderBy: 'id');
    if (res.isEmpty) {
      return _logService.log('No saved playlist');
    }

    final currentID =
        res.firstWhereOrNull((e) => (e['is_current'] as int) == 1)?['song_id'] as int? ??
        -1;
    if (currentID < 0) {
      return _logService.log('There is no current song', .error);
    }

    final songList = res.map((e) => e['song_id'] as int).toList();
    _logService.log(
      'Recovered playlist (${res[0]['list_name']}): $songList, current: $currentID',
    );

    _songService.currentSongID = currentID;
    Globals.showMinimizedPlayer.value = true;
    Globals.setDuplicate = true;

    await registerPlaylist(
      '${res[0]['list_name'] ?? '[null]'}'.trim(),
      songList,
      currentID,
      saveList: false,
      shouldShuffle: false,
    );
  }

  /// Only from _player
  void changeShuffleMode() {
    _shuffle = isShuffled ? .none : .all;

    if (isShuffled) _shufflePlaylist(beginSongID: _songService.currentSongID);
    _logService.log('Changed shuffle: $isShuffled');
    _configService.saveConfig();
  }

  /// Only from player
  Future<void> changeRepeatMode() async {
    _repeat = switch (_repeat) {
      .all => .one,
      .one => .none,
      .none => .all,
      .group => throw UnimplementedError('Group repeat mode should not be reachable.'),
    };

    _logService.log('Change repeat: ${_repeat.name}');
    _configService.saveConfig();
  }

  void moveSong(int from, int to) {
    if (from < 0 || from >= _playlist.length || to < 0 || to >= _playlist.length) {
      return _logService.log('Invalid move song index', .error);
    }

    int songIdx = _playlist.removeAt(from);
    _playlist.insert(to, songIdx);
    savePlaylist(_songService.currentSongID);
  }

  void loadConfig(bool? shuffle, String? repeat) {
    _shuffle = shuffle == true ? .all : .none;
    _repeat = switch (repeat) {
      'all' => .all,
      'one' => .one,
      _ => .none,
    };
  }

  void _shufflePlaylist({
    bool currentToStart = true,
    int beginSongID = -1,
    bool saveList = true,
  }) {
    _logService.log('Shuffling playlist');
    _playlist.shuffle();

    if (currentToStart) {
      if (beginSongID < 0) {
        _logService.log('A begin song should be selected', .error);
      } else {
        _playlist.removeWhere((e) => e == beginSongID);
        _playlist.insert(0, beginSongID);
        if (saveList) savePlaylist(beginSongID);
      }
    }
    _logService.log(
      'Current playlist song index: ${_playlist.indexWhere((e) => e == _songService.currentSongID)}',
    );
  }
}
