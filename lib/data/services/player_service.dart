import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_hub/data/models/music_track.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/constants.dart' show TableNames;
import 'package:music_hub/utils/extensions.dart' show DurationFromNumber, WhereOrNull;
import 'package:music_hub/utils/globals.dart';

class PlayerService extends BaseAudioHandler {
  // Streams
  final _onSongChangeController = StreamController<bool>.broadcast();
  late Stream<bool> onSongChange;

  final _onPlayingChangeController = StreamController<bool>.broadcast();
  late Stream<bool> onPlayingChange;

  // Player
  late final AudioPlayer _player;

  AudioPlayer get player => _player;

  bool get playing => _player.playing;

  // Playlist
  late List<int> _playlist; // Only keep track of IDs

  List<int> get playlist => _playlist;

  int get songCount => _playlist.length;

  String playlistName = '';

  String get playlistDisplayName =>
      '$playlistName ($songCount song${songCount > 1 ? 's' : ''})';

  // Play mode
  AudioServiceShuffleMode _shuffle = .none;
  AudioServiceRepeatMode _repeat = .none;

  bool get isShuffled => _shuffle == .all;

  AudioServiceRepeatMode get repeatMode => _repeat;

  // Listen count
  Duration _prevPos = 0.ms, _totalDuration = 0.ms;
  int _listenedDuration = 0, _minTime = 0;
  bool _listened = false;

  double get minTimePercent => _minTime / _totalDuration.inMilliseconds;

  // Skip cooldown
  bool _skipping = false;

  // Services
  final LogService _logService;
  final ConfigService _configService;
  final DatabaseService _databaseService;
  final SongService _songService;

  PlayerService({
    required LogService logService,
    required ConfigService configService,
    required DatabaseService databaseService,
    required SongService songService,
  }) : _logService = logService,
       _configService = configService,
       _databaseService = databaseService,
       _songService = songService {
    _logService.log('Audio Handler init');
    onSongChange = _onSongChangeController.stream;
    onPlayingChange = _onPlayingChangeController.stream;

    _playlist = [];

    _player = AudioPlayer();
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    setVolume(_configService.volume);

    _player.processingStateStream.listen((state) async {
      if (state == .completed) {
        switch (_repeat) {
          case .one:
            _logService.log('Repeat one, restarting song');
            await seek(0.ms);
            break;
          case .all:
            skipToNext(shouldDelay: true);
            break;
          case .none:
            pause();
          default:
            break;
        }
      }
    });

    _player.positionStream.listen((position) {
      int totalMilliseconds = _totalDuration.inMilliseconds;

      // Stops when play count is already incremented
      if (_listened) return;

      // Longer than length limit, to be safe
      if (totalMilliseconds >= _configService.lengthLimitMilliseconds) {
        int interval = position.inMilliseconds - _prevPos.inMilliseconds;
        // If rewind, skip
        if (interval > 0) {
          if (interval < 1000) {
            _listenedDuration += interval;
          }
          if (!_listened && _listenedDuration >= _minTime) {
            _songService.allSongs
                .firstWhere((e) => e.id == _songService.currentSongID)
                .incrementTimePlayed();
            _listened = true;
          }
        }
        _prevPos = position;
      }
    });

    _player.playingStream.listen((playing) {
      _onPlayingChangeController.add(playing);
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> setPlayerSong(int songID, {bool shouldPlay = true}) async {
    Duration? duration = _player.duration;

    if (songID < 0) {
      throw ArgumentError('Tried to set song of ID -1');
    }
    if (!Globals.setDuplicate && songID == _songService.currentSongID) return;
    if (Globals.setDuplicate) Globals.setDuplicate = false;

    assert(songID >= 0, 'Invalid song ID: $songID');

    Song song = _songService.allSongs.firstWhere((e) => e.id == songID);

    _logService.log('Switching song: (${song.id}) ${song.name}');
    duration = await _player.setAudioSource(
      AudioSource.uri(Uri.parse(Uri.encodeComponent(song.fullPath))),
    );

    _songService.currentSongID = songID;
    Globals.showMinimizedPlayer = true;

    String imgPath = song.imagePath;
    if (imgPath.isEmpty) {
      imgPath =
          _songService.albums
              .firstWhereOrNull((e) => e.name == _songService.savedPlaylistName)
              ?.imagePath ??
          '';
    }

    addMediaItem(
      MediaItem(
        id: '$songID',
        title: song.name,
        artist: song.artist,
        duration: duration,
        artUri: Uri.parse('file://$imgPath'),
      ),
    );

    // Reset song listen duration trackers
    _prevPos = 0.ms;
    _totalDuration = duration ?? 0.ms;
    _listenedDuration = 0;
    _listened = false;
    _minTime = min(
      max((_totalDuration.inMilliseconds * 0.1).round(), 10000),
      _totalDuration.inMilliseconds,
    );

    // Broadcast change
    _onSongChangeController.add(true);

    if (_totalDuration.inMilliseconds <= 0) {
      _logService.log('Something is wrong when setting audio source');
    } else {
      _logService.log('Min listen time: $_minTime / ${_totalDuration.inMilliseconds} ms');
    }

    if (shouldPlay && _configService.autoPlayNewSong) {
      play();
    } else {
      pause();
    }
  }

  Future<void> registerPlaylist(
    String name,
    List<int> list,
    int beginSongID, {
    bool saveList = true,
    bool shouldShuffle = true,
  }) async {
    _playlist = list;

    if (shouldShuffle && _shuffle == .all) {
      _shufflePlaylist(beginSongID: beginSongID, saveList: false);
    }

    int songCount = _playlist.length;
    playlistName = name;
    if (saveList) savePlaylist(beginSongID);
    _logService.log('Registered playlist: $playlistName ($songCount songs)');
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

    _songService.savedPlaylistName = '${res[0]['list_name']}'.trim();
    _songService.currentSongID = currentID;
    Globals.showMinimizedPlayer = true;
    Globals.setDuplicate = true;

    await registerPlaylist(
      _songService.savedPlaylistName!,
      songList,
      currentID,
      saveList: false,
      shouldShuffle: false,
    );
  }

  void savePlaylist(int currentID) {
    _databaseService.db.delete(TableNames.playlistTable).then((_) {
      _logService.log('Saving playlist ($playlistName): $playlist, current: $currentID');
      _songService.savedPlaylistName = playlistName;

      final data = _playlist.map(
        (e) => <String, Object?>{
          'list_name': playlistName.trim(),
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
    if (playlistName != _songService.savedPlaylistName) return savePlaylist(newID);

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

  /// Returns the current song duration in milliseconds
  int get currentDuration =>
      _songService.currentSongID >= 0 ? _player.position.inMilliseconds : 0;

  /// Returns the current song duration in milliseconds
  int get totalDuration =>
      _songService.currentSongID >= 0 ? _player.duration?.inMilliseconds ?? 1 : 1;

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

  void moveSong(int from, int to) {
    if (from < 0 || from >= _playlist.length || to < 0 || to >= _playlist.length) {
      return _logService.log('Invalid move song index', .error);
    }

    int songIdx = _playlist.removeAt(from);
    _playlist.insert(to, songIdx);
    savePlaylist(_songService.currentSongID);
  }

  Future<void> addMediaItem(MediaItem item) async => mediaItem.add(item);

  Future<void> updateNotificationInfo({required int songID, Duration? duration}) async {
    if (mediaItem.value == null) return;
    final song = _songService.allSongs.firstWhereOrNull((e) => e.id == songID);
    _logService.log('Updating media item of $songID');

    if (song == null) {
      return _logService.log('Song not found', .error);
    }

    String imgPath = song.imagePath;
    if (imgPath.isEmpty) {
      imgPath =
          _songService.albums
              .firstWhereOrNull((e) => e.name == _songService.savedPlaylistName)
              ?.imagePath ??
          '';
    }

    mediaItem.add(
      MediaItem(
        id: '$songID',
        title: song.name,
        artist: song.artist,
        duration: duration ?? mediaItem.value!.duration,
        artUri: Uri.parse('file://$imgPath'),
      ),
    );
  }

  Future<void> setVolume(double volume) async => _player.setVolume(volume);

  @override
  Future<void> play() async {
    if (_songService.currentSongID < 0) return;

    if (_player.processingState == .completed) {
      seek(0.ms);
    }
    _player.play();
    _onPlayingChangeController.add(true);
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

  @override
  Future<void> pause() async {
    _player.pause();
    _onPlayingChangeController.add(false);
  }

  @override
  Future<void> stop() async {
    _player.stop();
    _onPlayingChangeController.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    _player.seek(position.inMilliseconds.clamp(0, _totalDuration.inMilliseconds).ms);
  }

  @override
  Future<void> skipToNext({bool shouldDelay = false}) async {
    if (_skipping) return;

    _logService.log('Skipping to next song');
    _skipping = true;

    if (_playlist.isEmpty) {
      pause();
      return _logService.log('Playlist is empty, this should not be the case', .error);
    }

    if (_playlist.length == 1) {
      return _logService.log('Playlist only has one song, skipping action');
    }

    int currentIndex = _playlist.indexWhere((e) => e == _songService.currentSongID);

    if (currentIndex < 0) {
      pause();
      return _logService.log(
        'Can\'t find song in playlist, this should not be the case',
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
          await setPlayerSong(_playlist[0]);
          await updateSavedPlaylist(currentIndex, 0);
          break;
        case AudioServiceRepeatMode.none:
          if (_player.processingState == ProcessingState.completed) {
            _logService.log('Repeat none');
            pause();
          }
          break;
        default:
          await setPlayerSong(_playlist[0]);
          await updateSavedPlaylist(currentIndex, 0);
          break;
      }
    } else {
      await setPlayerSong(_playlist[currentIndex + 1]);
      await updateSavedPlaylist(_playlist[currentIndex], _playlist[currentIndex + 1]);
    }
    _skipping = false;
  }

  @override
  Future<void> skipToPrevious() async {
    if (_skipping) return;

    _logService.log('Skipping to previous song');
    _skipping = true;

    if (_playlist.isEmpty) {
      pause();
      return _logService.log('Playlist is empty, this should not be the case', .error);
    }

    if (_playlist.length == 1) {
      return _logService.log('Playlist only contains one song, skipping action');
    }

    int currentIndex = _playlist.indexWhere((e) => e == _songService.currentSongID);

    if (currentIndex < 0) {
      pause();
      return _logService.log('Current ID is < 0, this should not be the case', .error);
    }

    final newIndex = (currentIndex == 0 ? _playlist.length : currentIndex) - 1;

    await updateSavedPlaylist(_songService.currentSongID, _playlist[newIndex]);
    await setPlayerSong(_playlist[newIndex]);

    _skipping = false;
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!playbackState.value.playing) stop();
  }

  void loadConfig(bool? shuffle, String? repeat) {
    setVolume(_configService.volume);
    _shuffle = shuffle == true ? .all : .none;
    _repeat = switch (repeat) {
      'all' => .all,
      'one' => .one,
      _ => .none,
    };
  }
}
