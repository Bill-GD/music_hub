import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:music_hub/data/database/database.dart';
import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/utils.dart';

class SongService {
  final _logService = get<LogService>(),
      _configService = get<ConfigService>(),
      _database = get<MusicDatabase>();

  final List<Song> _songs = [];

  int currentSongID = -1;

  final lyricChangedController = StreamController<void>.broadcast();

  List<Song> get songs => _songs;

  List<int> get idList => _songs.map((s) => s.id).toList();

  Song get random => _songs[Random().nextInt(_songs.length)];

  Song? getSong(int id) => _songs.firstWhereOrNull((e) => e.id == id);

  bool hasSong(int id) => getSong(id) != null;

  void sortAllSongs([SortOptions? sortType]) {
    final tracks = List<Song>.from(_songs);
    _configService.currentSortOption = sortType ?? _configService.currentSortOption;
    _logService.log('Sorting all songs: ${_configService.currentSortOption.name}');
    switch (_configService.currentSortOption) {
      case .id:
        tracks.sort((track1, track2) => track1.id.compareTo(track2.id));
      case .name:
        tracks.sort(
          (track1, track2) =>
              track1.name.toLowerCase().compareTo(track2.name.toLowerCase()),
        );
      case .mostPlayed:
        tracks.sort(
          (track1, track2) => track2.timeListened.compareTo(track1.timeListened),
        );
      case .recentlyAdded:
        tracks.sort((track1, track2) => track2.timeAdded.compareTo(track1.timeAdded));
    }
    _songs.clear();
    _songs.addAll(tracks);
  }

  /// Updates list of all songs
  Future<void> loadSongs({void Function(String text)? updateToast}) async {
    final storageSongs = await _getSongsFromStorage(updateToast: updateToast);
    updateToast?.call('Fetching saved songs');
    final savedSongs = await _database.allSongs;

    int updateCount = 0;

    _logService.log('Updating saved song data');
    for (int i = 0; i < savedSongs.length; i++) {
      updateToast?.call('Updating song: ${i + 1}/${savedSongs.length}');
      final matchingSong = storageSongs.firstWhereOrNull(
        (e) => e.path.value == savedSongs[i].path,
      );

      if (matchingSong == null) {
        if (!savedSongs[i].deleted) {
          updateCount++;
          await (_database.update(_database.song)
                ..where((s) => s.id.equals(savedSongs[i].id)))
              .write(SongCompanion(deleted: Value(true)));
        }
        continue;
      }

      final updated = savedSongs[i].copyWith(name: matchingSong.name.value);
      await _database.update(_database.song).replace(updated);
      storageSongs.remove(matchingSong);
    }

    int insertCount = 0;
    for (final s in storageSongs) {
      await _database.into(_database.song).insert(s);
      insertCount++;
    }

    _songs
      ..clear()
      ..addAll((await _database.allSongs).map(Song.fromData));
    _logService.log('Loaded songs: $updateCount updates, $insertCount inserts');
  }

  Future<List<SongCompanion>> _getSongsFromStorage({
    void Function(String text)? updateToast,
  }) async {
    final downloadDir = Directory(Paths.downloadPath);
    _logService.log('Getting mp3 files from: ${downloadDir.path}');

    final mp3Files = downloadDir
        .listSync()
        .where((e) => e.path.endsWith('.mp3'))
        .toList();

    _logService.log('Found ${mp3Files.length} mp3 files');

    Future<SongCompanion> makeCompanion(FileSystemEntity e) async {
      final file = File(e.path);
      final stat = await file.stat();
      final fileName = e.path.split(Paths.downloadPath).last;
      final displayName = fileName.split('.mp3').first;
      return SongCompanion.insert(
        path: fileName,
        name: displayName,
        artist: 'Unknown',
        timeAdded: Value(stat.modified),
      );
    }

    if (!_configService.enableSongFiltering) {
      return await Future.wait(mp3Files.map(makeCompanion).toList());
    }

    _logService.log(
      'Filtering songs shorter than ${_configService.lengthLimitMilliseconds ~/ 1000}s',
    );

    int count = 0;
    final futures = mp3Files.map((f) {
      return Future(() async {
        try {
          final file = File(f.path);
          final info = await MetadataRetriever.fromFile(file).timeout(
            5.seconds,
            onTimeout: () {
              throw TimeoutException('Metadata retrieval timeout');
            },
          );
          final duration = info.trackDuration ?? 0;
          SongCompanion? res;
          if (duration >= _configService.lengthLimitMilliseconds) {
            res = await makeCompanion(f);
          }
          updateToast?.call('Reading metadata: ${++count}/${mp3Files.length}');
          return res;
        } catch (e) {
          _logService.log('Metadata read failed for ${f.path}: $e', .error);
          return null;
        }
      });
    });

    final results = await Future.wait(futures);
    return results.whereType<SongCompanion>().toList();
  }
}
