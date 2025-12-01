import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart' show Paths;
import 'package:music_hub/utils/extensions.dart' show WhereOrNull;

class SongService {
  final _logService = GetIt.I<LogService>();
  final _configService = GetIt.I<ConfigService>();
  final _databaseService = GetIt.I<DatabaseService>();

  final List<Song> _songs = [];

  int currentSongID = -1;
  String? savedPlaylistName;

  final lyricChangedController = StreamController<void>.broadcast();

  List<Song> get songs => List.from(_songs);

  List<int> get idList => _songs.map((s) => s.id).toList();

  Song get random => _songs[Random().nextInt(_songs.length)];

  Song? getSong(int id) {
    return _songs.firstWhereOrNull((e) => e.id == id);
  }

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
  Future<void> updateSongList() async {
    final storageSongs = await _getSongsFromStorage();
    final savedSongs = await _getSongsFromDatabase();

    int updateCount = 0;

    _logService.log('Updating saved song data');
    for (int i = 0; i < savedSongs.length; i++) {
      final matchingSong = storageSongs.firstWhereOrNull(
        (e) => e.path == savedSongs[i].path,
      );

      if (matchingSong == null) {
        if (!savedSongs[i].deleted) {
          updateCount++;
          savedSongs[i].deleted = true;
          await savedSongs[i].update(false);
        }
        continue;
      }

      savedSongs[i]
        ..id = matchingSong.id
        ..name = matchingSong.name
        ..artist = matchingSong.artist
        ..timeListened = matchingSong.timeListened
        ..lyricPath = matchingSong.lyricPath
        ..imagePath = matchingSong.imagePath
        ..deleted = false;
      storageSongs.remove(matchingSong);
    }

    int insertCount = 0;
    for (final s in storageSongs) {
      await s.insert();
      insertCount++;
    }
    _logService.log(
      'Finishing getting songs: $updateCount updates, $insertCount inserts',
    );

    _songs.clear();
    _songs.addAll(savedSongs);
    _songs.addAll(storageSongs);
  }

  Future<List<Song>> _getSongsFromStorage() async {
    final downloadDir = Directory(Paths.downloadPath);
    _logService.log('Getting mp3 files from: ${downloadDir.path}');

    final mp3Files = downloadDir
        .listSync()
        .where((e) => e.path.endsWith('.mp3'))
        .toList();

    if (!_configService.enableSongFiltering) {
      return mp3Files.map((e) {
        return Song(
          e.path.split(Paths.downloadPath).last,
          timeAdded: e.statSync().modified,
        );
      }).toList();
    }

    _logService.log(
      'Filtering songs shorter than ${_configService.lengthLimitMilliseconds ~/ 1000}s',
    );
    final filteredFiles = <Song>[];
    for (final file in mp3Files) {
      final info = await MetadataRetriever.fromFile(File(file.path));
      if (info.trackDuration! >= _configService.lengthLimitMilliseconds) {
        filteredFiles.add(
          Song(
            file.path.split(Paths.downloadPath).last,
            timeAdded: file.statSync().modified,
          ),
        );
      }
    }
    return filteredFiles;
  }

  Future<List<Song>> _getSongsFromDatabase() async {
    _logService.log('Getting songs from database');
    final json = await _databaseService.db.rawQuery(
      'select t.*, a.name album from music_track t '
      'inner join album_tracks at on t.id = at.track_id '
      'inner join album a on a.id = at.album_id '
      'where t.deleted = 0;',
    );
    return json.map(Song.fromJson).toList();
  }
}
