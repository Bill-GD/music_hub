import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart' show Paths, TableNames;
import 'package:music_hub/utils/extensions.dart' show WhereOrNull;

class SongService {
  final LogService _logService = GetIt.I();
  final ConfigService _configService = GetIt.I();
  final DatabaseService _databaseService = GetIt.I();

  final List<Song> allSongs = [];
  final Map<String, int> artists = {};
  final List<Album> albums = [];

  int currentSongID = -1;
  String? savedPlaylistName;

  final lyricChangedController = StreamController<void>.broadcast();

  Song get random => allSongs[Random().nextInt(allSongs.length)];

  Song? getSong(int id) {
    return allSongs.firstWhereOrNull((e) => e.id == id);
  }

  bool hasSong(int id) => getSong(id) != null;

  /// Get all songs (from storage & saved)
  Future<void> loadData() async {
    await _updateSongList();
    updateArtistList();
    await updateAlbumList();
  }

  void sortAllSongs([SortOptions? sortType]) {
    final tracks = List<Song>.from(allSongs);
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
    allSongs.clear();
    allSongs.addAll(tracks);
  }

  /// Updates all songs with saved data
  Future<void> _updateSongList() async {
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

    allSongs.clear();
    allSongs.addAll(savedSongs);
    allSongs.addAll(storageSongs);
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

  void updateArtistList() {
    _logService.log('Updating artist list');
    final unsortedArtists = <String, int>{}
      ..addAll({
        for (final song in allSongs)
          song.artist: allSongs.where((s) => s.artist == song.artist).length,
      });
    artists.clear();
    artists.addAll(
      SplayTreeMap.from(
        unsortedArtists,
        (key1, key2) => key1.toLowerCase().compareTo(key2.toLowerCase()),
      ),
    );
  }

  Future<void> updateAlbumList() async {
    _logService.log('Updating album list');
    final fetchedAlbums = (await _databaseService.db.query(
      TableNames.albumTable,
    )).map(Album.fromJson).toList();
    albums.clear();

    if (fetchedAlbums.isEmpty) {
      _logService.log("No album exists, creating default album 'Unknown'");
      final unknown = Album(name: 'Unknown', id: -1, timeAdded: DateTime.now())
        ..songs = allSongs.map((e) => e.id).toList()
        ..insert();
      albums.add(unknown);
      return;
    }

    for (final a in fetchedAlbums) {
      var s = await _databaseService.db.query(
        TableNames.albumSongsTable,
        where: 'album_id = ?',
        whereArgs: [a.id],
        columns: ['track_order', 'track_id'],
        orderBy: 'track_order',
      );
      // LogHandler.log('$s');
      final idList = s.map((e) => e['track_id'] as int).where((e) => hasSong(e));
      for (final id in idList) {
        final addingSongIdx = allSongs.indexWhere((e) => e.id == id);
        if (addingSongIdx < 0 || allSongs[addingSongIdx].hasAlbum) continue;
        allSongs[addingSongIdx].hasAlbum = true;
      }
      a.songs.addAll(idList);
      _logService.log('Got album: id=${a.id}, n=${a.name}, l=${a.songs.length}');
    }

    fetchedAlbums.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final noAlbumSongs = allSongs.where((e) => !e.hasAlbum);
    final unknown = fetchedAlbums.firstWhereOrNull((a) => a.id == 1);
    if (unknown != null) {
      for (final e in noAlbumSongs) {
        // LogHandler.log('Adding song (${e.id}) to Unknown album');
        e.hasAlbum = true;
        unknown.songs.add(e.id);
      }
      unknown.update();
    }

    albums.addAll(fetchedAlbums);
  }
}
