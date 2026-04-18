import 'package:drift/drift.dart';

import 'package:music_hub/data/database/database.dart';
import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/utils.dart';

class Song {
  int id, timeListened;
  String path, name, artist, lyricPath, imagePath;
  DateTime timeAdded = DateTime.now();
  bool hasAlbum = false;
  bool deleted = false;

  String get fullPath => Paths.downloadPath + path;

  Song(
    this.path, {
    this.id = -1,
    this.name = '',
    this.artist = 'Unknown',
    this.timeListened = 0,
    this.lyricPath = '',
    this.imagePath = '',
    required this.timeAdded,
  }) {
    name = name.isEmpty ? path.split('/').last.split('.mp3').first : name;
  }

  Song.fromData(SongData songData)
    : id = songData.id,
      path = songData.path,
      name = songData.name,
      artist = songData.artist,
      timeListened = songData.timeListened,
      lyricPath = songData.lyricPath,
      imagePath = songData.imagePath,
      timeAdded = songData.timeAdded,
      deleted = songData.deleted;

  Future<void> incrementTimePlayed() async {
    timeListened++;
    get<LogService>().log('Play count +1 for ($id)');

    final db = get<MusicDatabase>();
    await (db.update(db.song)..where((s) => s.id.equals(id))).write(
      SongCompanion(timeListened: Value(timeListened)),
    );
  }

  // Future<void> insert() async {
  //   final logService = get<LogService>();
  //   if (id >= 0) {
  //     return logService.log('Trying to duplicate song record (id=$id)', .error);
  //   }
  //   // id = await get<DatabaseService>().db.insert(
  //   //   TableNames.songTable,
  //   //   toJson()..remove('id'),
  //   // );
  //   // logService.log('Inserted song -> new id: $id');
  // }

  Future<void> update([bool log = true]) async {
    final logService = get<LogService>(), db = get<MusicDatabase>();
    if (id < 0) {
      return logService.log('Trying to update song id -1', .error);
    }
    if (log) logService.log('Updating song: $id');
    await (db.update(db.song)..where((s) => s.id.equals(id))).write(
      SongCompanion(
        id: Value(id),
        path: Value(path),
        name: Value(name),
        artist: Value(artist),
        imagePath: Value(imagePath),
        lyricPath: Value(lyricPath),
        timeAdded: Value(timeAdded),
        timeListened: Value(timeListened),
        deleted: Value(deleted),
      ),
    );
  }

  Future<void> delete() async {
    final logService = get<LogService>(), db = get<MusicDatabase>();

    if (id < 0) {
      return logService.log('Trying to delete song id -1', .error);
    }
    await db.batch((batch) {
      // await dbService.db.delete(TableNames.songTable, where: 'id = ?', whereArgs: [id]);
      batch.update(
        db.song,
        SongCompanion(deleted: Value(true)),
        where: (s) => s.id.equals(id),
      );
      batch.deleteWhere(db.albumSong, (as) => as.trackId.equals(id));
    });
    logService.log('Deleted song: $id');
  }

  Future<void> removeFromPlaylist(int albumID) async {
    final db = get<MusicDatabase>();

    get<LogService>().log('Removing song ($id) from album ($albumID)');

    final res = await (db.select(
      db.albumSong,
    )..where((as) => as.trackId.equals(id) & as.albumId.equals(albumID))).get();

    db.batch((batch) {
      batch.deleteWhere(
        db.albumSong,
        (as) => as.trackId.equals(id) & as.albumId.equals(albumID),
      );

      batch.customStatement(
        'update ${db.albumSong.tableName} '
        'set track_order = track_order - 1 '
        'where album_id = ? and track_order > ?',
        [Variable.withInt(albumID), Variable.withInt(res.first.trackOrder)],
      );
    });

    final otherAlbums = get<AlbumService>().albums.where(
      (a) => a.id != 1 && a.id != albumID,
    );
    final unknown = get<AlbumService>().albums.firstWhere((e) => e.id == 1);

    if (otherAlbums.any((a) => a.songs.contains(id)) || unknown.songs.contains(id)) {
      return;
    }
    unknown.songs.add(id);
    await unknown.update();
  }
}
