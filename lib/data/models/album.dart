import 'package:drift/drift.dart';

import 'package:music_hub/data/database/database.dart';
import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/utils.dart';

class Album {
  int id;
  String name;
  DateTime timeAdded;
  String imagePath;
  List<int> songs = [];

  Album({required this.name, this.id = -1, this.imagePath = '', required this.timeAdded});

  Album.fromData(AlbumData albumData)
    : id = albumData.id,
      name = albumData.name,
      imagePath = albumData.imagePath,
      timeAdded = albumData.timeAdded;

  Album.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? -1,
      name = json['name'],
      imagePath = json['image_path'] ?? '',
      timeAdded = DateTime.parse(json['time_added']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_path': imagePath,
    'time_added': timeAdded.toIso8601String(),
  };

  static Future<void> insert(
    AlbumCompanion newAlbum, {
    List<int> songs = const [],
  }) async {
    final logService = get<LogService>(), db = get<MusicDatabase>();

    final insertedAlbum = await db.into(db.album).insertReturning(newAlbum);

    logService.log('Inserted album -> new id: ${insertedAlbum.id}');
    await db.batch((batch) {
      batch.insertAll(
        db.albumSong,
        songs.mapIndexed(
          (i, s) => AlbumSongCompanion.insert(
            trackOrder: i,
            trackId: s,
            albumId: insertedAlbum.id,
          ),
        ),
      );
    });
  }

  Future<void> update() async {
    final logService = get<LogService>(), db = get<MusicDatabase>();

    if (id < 0) {
      return logService.log('Trying to update album id -1', .error);
    }
    await db.batch((batch) {
      batch.update(
        db.album,
        AlbumCompanion(
          id: Value(id),
          name: Value(name),
          imagePath: Value(imagePath),
          timeAdded: Value(timeAdded),
        ),
        where: (a) => a.id.equals(id),
      );
      batch.deleteWhere(db.albumSong, (as) => as.albumId.equals(id));
      batch.insertAll(
        db.albumSong,
        songs.mapIndexed(
          (i, s) => AlbumSongCompanion.insert(trackOrder: i, trackId: s, albumId: id),
        ),
      );
    });
    logService.log('Updated album ($id)');
  }

  Future<void> delete() async {
    final logService = get<LogService>(), db = get<MusicDatabase>(), albumService = get<AlbumService>();

    if (id < 0) {
      return logService.log('Trying to delete album id -1', .error);
    }

    await db.batch((batch) {
      batch.deleteWhere(db.album, (a) => a.id.equals(id));
      batch.deleteWhere(db.albumSong, (as) => as.albumId.equals(id));
    });

    final otherAlbums = albumService.albums.where((a) => a.id != 1 && a.id != id);
    final unknown = albumService.albums.firstWhere((e) => e.id == 1);

    for (final s in songs) {
      if (otherAlbums.any((a) => a.songs.contains(s)) || unknown.songs.contains(s)) {
        continue;
      }
      unknown.songs.add(s);
    }
    await unknown.update();
    logService.log('Deleted album ($id)');
  }
}
