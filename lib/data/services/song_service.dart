import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart' show Paths, TableNames;
import 'package:music_hub/utils/extensions.dart' show WhereOrNull;

class SongService {
  List<Song> allSongs = [];
  Map<String, int> artists = {};
  List<Album> albums = [];

  int currentSongID = -1;
  String? savedPlaylistName;

  final lyricChangedController = StreamController<void>.broadcast();

  final LogService _logService;
  final ConfigService _configService;
  final DatabaseService _databaseService;

  SongService({
    required LogService logService,
    required ConfigService configService,
    required DatabaseService databaseService,
  }) : _logService = logService,
       _configService = configService,
       _databaseService = databaseService;

  /// Get all songs (from storage & saved)
  Future<void> updateMusicData() async {
    await updateListOfSongs();
    updateArtistsList();
    await updateAlbumList();
  }

  bool hasSong(int id) {
    return allSongs.firstWhereOrNull((e) => e.id == id) != null;
  }

  /// Updates all songs with saved data
  Future<void> updateListOfSongs() async {
    List<Song> storageSongs = await _getSongsFromStorage();
    List<Song> savedSongs = await _getSavedMusicData();

    _logService.log('Updating music data from saved');
    for (int i = 0; i < storageSongs.length; i++) {
      final matchingSong = savedSongs.firstWhereOrNull(
        (e) => e.path == storageSongs[i].path,
      );

      if (matchingSong == null) continue;

      storageSongs[i]
        ..id = matchingSong.id
        ..name = matchingSong.name
        ..artist = matchingSong.artist
        ..timeListened = matchingSong.timeListened
        ..lyricPath = matchingSong.lyricPath
        ..imagePath = matchingSong.imagePath;
    }

    final updateCount = storageSongs.where((e) => e.id >= 0).length;
    final insertCount = storageSongs.length - updateCount;

    _logService.log(
      'Finishing getting songs: $updateCount updates, $insertCount inserts',
    );
    for (final s in storageSongs) {
      if (s.id >= 0) {
        await s.update(false);
      } else {
        await s.insert();
      }
    }
    allSongs = storageSongs;
  }

  Future<List<Song>> _getSongsFromStorage() async {
    final downloadDir = Directory(Paths.downloadPath);
    _logService.log('Getting mp3 files from: ${downloadDir.path}');
    final mp3Files = downloadDir
        .listSync()
        .where((e) => e.path.endsWith('.mp3'))
        .toList();
    final filteredFiles = <Song>[];

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

  Future<List<Song>> _getSavedMusicData() async {
    _logService.log('Getting data from database');
    final json = await _databaseService.db.rawQuery(
      'select t.*, a.name album from music_track t '
      'inner join album_tracks at on t.id = at.track_id '
      'inner join album a on a.id = at.album_id;',
    );
    return json.map(Song.fromJson).toList();
  }

  void sortAllSongs([SortOptions? sortType]) {
    final tracks = List<Song>.from(allSongs);
    _configService.currentSortOption = sortType ?? _configService.currentSortOption;
    _logService.log('Sorting all songs: ${_configService.currentSortOption.name}');
    switch (_configService.currentSortOption) {
      case SortOptions.id:
        tracks.sort((track1, track2) => track1.id.compareTo(track2.id));
        break;
      case SortOptions.name:
        tracks.sort(
          (track1, track2) =>
              track1.name.toLowerCase().compareTo(track2.name.toLowerCase()),
        );
        break;
      case SortOptions.mostPlayed:
        tracks.sort(
          (track1, track2) => track2.timeListened.compareTo(track1.timeListened),
        );
        break;
      case SortOptions.recentlyAdded:
        tracks.sort((track1, track2) => track2.timeAdded.compareTo(track1.timeAdded));
        break;
    }
    allSongs = tracks;
  }

  void updateArtistsList() {
    _logService.log('Updating artist list');
    final unsortedArtists = <String, int>{}
      ..addAll({
        for (final song in allSongs) //
          song.artist: allSongs.where((s) => s.artist == song.artist).length,
      });
    artists = SplayTreeMap.from(
      unsortedArtists,
      (key1, key2) => key1.toLowerCase().compareTo(key2.toLowerCase()),
    );
  }

  Future<void> updateAlbumList() async {
    _logService.log('Updating album list');
    final fetchedAlbums = (await _databaseService.db.query(
      TableNames.albumTable,
    )).map(Album.fromJson).toList();

    if (fetchedAlbums.isEmpty) {
      _logService.log("No album exists, creating default album 'Unknown'");
      final unknown = Album(name: 'Unknown', id: -1, timeAdded: DateTime.now())
        ..songs = allSongs.map((e) => e.id).toList()
        ..insert();
      albums = [unknown];
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
      _logService.log(
        'Got album: id=${a.id}, n=${a.name}, l=${a.songs.length}, s=${a.songs}',
      );
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

    albums = fetchedAlbums;
  }
}
