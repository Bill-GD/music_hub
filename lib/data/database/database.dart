import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:music_hub/data/database/schemas/album.dart';
import 'package:music_hub/data/database/schemas/album_song.dart';
import 'package:music_hub/data/database/schemas/playlist.dart';
import 'package:music_hub/data/database/schemas/song.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/utils.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Song, Album, Playlist, AlbumSong])
class MusicDatabase extends _$MusicDatabase {
  final _logService = get<LogService>();

  MusicDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'database');
  }

  Future<List<AlbumData>> get allAlbums => select(album).get();

  Future<List<AlbumSongData>> get allAlbumSongs => select(albumSong).get();

  Future<List<SongData>> get allSongs => (select(song).join([
    innerJoin(albumSong, albumSong.trackId.equalsExp(song.id), useColumns: false),
    innerJoin(album, album.id.equalsExp(albumSong.albumId), useColumns: false),
  ])..where(song.deleted.equals(false))).map((row) => row.readTable(song)).get();

  Future<List<PlaylistData>> get savedPlaylist =>
      (select(playlist)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<List<AlbumSongData>> albumSongs(int albumId) {
    return (select(albumSong)..where((as) => as.albumId.equals(albumId))).get();
  }

  /// Attempts to migrate old database location to new one.
  static Future<void> migrateDatabase(String oldPath) async {
    final oldFile = File(oldPath);
    if (!oldFile.existsSync()) return;

    final internalStorage = await getApplicationDocumentsDirectory();

    final newPath = '${internalStorage.absolute.path}/database.sqlite';
    final newFile = File(newPath);
    final logService = get<LogService>();

    try {
      oldFile.copySync(newPath);

      if (await newFile.exists() && await newFile.length() > 0) {
        logService.log('DB migrated to \'$newPath\'', .info);
      } else {
        logService.log('DB copy verification failed for \'$newPath\'', .error);
      }
    } catch (e) {
      logService.log('DB migration failed: $e', .error);
    }
  }

  Future<void> clearAllData() async {
    _logService.log(
      "This deletes all saved data. If used alone, it won't be recoverable.",
      .warn,
    );
    await delete(song).go();
    await delete(album).go();
    await delete(albumSong).go();
  }
}

extension SongDataExtension on SongData {
  String get fullPath => Paths.downloadPath + path;
}
