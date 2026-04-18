import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/playlist_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

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

  // Listen count
  Duration _prevPos = 0.ms, _totalDuration = 0.ms;
  int _listenedDuration = 0, _minTime = 0;
  bool _listened = false;

  double get minTimePercent => _minTime / _totalDuration.inMilliseconds;

  // Services
  final _logService = get<LogService>(),
      _configService = get<ConfigService>(),
      _songService = get<SongService>(),
      _albumService = get<AlbumService>(),
      _playlistService = get<PlaylistService>();

  PlayerService() {
    _logService.log('Player service init');
    onSongChange = _onSongChangeController.stream;
    onPlayingChange = _onPlayingChangeController.stream;

    _player = AudioPlayer();
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    setVolume(_configService.volume);

    _player.processingStateStream.listen((state) async {
      if (state == .completed) {
        switch (_playlistService.repeatMode) {
          case .one:
            _logService.log('Repeat one, restarting song');
            await seek(0.ms);
          case .all:
            skipToNext(shouldDelay: true);
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
            _songService.songs
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

    Song song = _songService.songs.firstWhere((e) => e.id == songID);

    _logService.log('Switching song: (${song.id}) ${song.name}');
    duration = await _player.setAudioSource(
      AudioSource.uri(Uri.parse(Uri.encodeComponent(song.fullPath))),
    );

    _songService.currentSongID = songID;
    Globals.showMinimizedPlayer.value = true;

    String imgPath = song.imagePath;
    if (imgPath.isEmpty) {
      imgPath =
          _albumService.albums
              .firstWhereOrNull((e) => e.name == _playlistService.playlistName)
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

  /// Returns the current song duration in milliseconds
  int get currentDuration =>
      _songService.currentSongID >= 0 ? _player.position.inMilliseconds : 0;

  /// Returns the current song duration in milliseconds
  int get totalDuration =>
      _songService.currentSongID >= 0 ? _player.duration?.inMilliseconds ?? 1 : 1;

  Future<void> addMediaItem(MediaItem item) async => mediaItem.add(item);

  Future<void> updateNotificationInfo({required int songID, Duration? duration}) async {
    if (mediaItem.value == null) return;
    final song = _songService.getSong(songID);
    _logService.log('Updating media item of $songID');

    if (song == null) {
      return _logService.log('Song not found', .error);
    }

    String imgPath = song.imagePath;
    if (imgPath.isEmpty) {
      imgPath =
          _albumService.albums
              .firstWhereOrNull((e) => e.name == _playlistService.playlistName)
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
  Future<void> skipToNext({bool shouldDelay = false}) async {
    final (songIndex, message, logLevel) = await _playlistService.nextSong();
    if ((_playlistService.repeatMode == .none && _player.processingState == .completed) ||
        (songIndex == null && message != null && logLevel != null)) {
      pause();
      _logService.log(message!, logLevel!);
      return;
    }

    if (shouldDelay && _configService.delayMilliseconds > 0) {
      await Future.delayed(
        _configService.delayMilliseconds.ms,
        () => _logService.log('Delayed for ${_configService.delayMilliseconds}ms'),
      );
    }
    await setPlayerSong(songIndex!);
    _playlistService.toggleSkippingCooldown(false);
  }

  @override
  Future<void> skipToPrevious() async {
    final (songIndex, message, logLevel) = await _playlistService.prevSong();
    if (songIndex == null && message != null && logLevel != null) {
      pause();
      _logService.log(message, logLevel);
      return;
    }
    await setPlayerSong(songIndex!);
    _playlistService.toggleSkippingCooldown(false);
  }

  @override
  Future<void> play() async {
    if (_songService.currentSongID < 0) return;

    if (_player.processingState == .completed) {
      seek(0.ms);
    }
    _player.play();
    _onPlayingChangeController.add(true);
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
  Future<void> onTaskRemoved() async {
    if (!playbackState.value.playing) stop();
  }

  void loadConfig(bool? shuffle, String? repeat) {
    setVolume(_configService.volume);
  }
}
