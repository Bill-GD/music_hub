import 'dart:io';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/constants.dart' show Paths, TableNames;

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

  Song.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      path = json['path'],
      name = json['name'] ?? json['path'].split('/').last.split('.mp3').first,
      artist = json['artist'] ?? 'Unknown',
      timeListened = json['timeListened'] ?? json['time_listened'] ?? 0,
      lyricPath = json['lyric_path'] ?? '',
      imagePath = json['image_path'] ?? '',
      timeAdded = json['time_added'] != null
          ? DateTime.parse(json['time_added'])
          : File('${Paths.downloadPath}${json['path']}').statSync().modified,
      deleted = json['delete'] ?? false;

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'name': name,
    'artist': artist,
    'time_listened': timeListened,
    'lyric_path': lyricPath,
    'image_path': imagePath,
    'time_added': timeAdded.toIso8601String(),
  };

  Future<void> incrementTimePlayed() async {
    timeListened++;
    GetIt.I<LogService>().log('Play count +1 for ($id)');
    await update(false);
  }

  Future<void> insert() async {
    final logService = GetIt.I<LogService>();
    if (id >= 0) {
      return logService.log('Trying to duplicate song record (id=$id)', .error);
    }
    id = await GetIt.I<DatabaseService>().db.insert(
      TableNames.songTable,
      toJson()..remove('id'),
    );
    logService.log('Inserted song -> new id: $id');
  }

  Future<void> update([bool log = true]) async {
    final logService = GetIt.I<LogService>();
    if (id < 0) {
      return logService.log('Trying to update song id -1', .error);
    }
    if (log) logService.log('Updating song: $id');
    await GetIt.I<DatabaseService>().db.update(
      TableNames.songTable,
      toJson(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete() async {
    final logService = GetIt.I<LogService>();
    final dbService = GetIt.I<DatabaseService>();

    if (id < 0) {
      return logService.log('Trying to delete song id -1', .error);
    }
    // await dbService.db.delete(TableNames.songTable, where: 'id = ?', whereArgs: [id]);
    await GetIt.I<DatabaseService>().db.update(
      TableNames.songTable,
      {'deleted': true},
      where: 'id = ?',
      whereArgs: [id],
    );
    await dbService.db.delete(
      TableNames.albumSongsTable,
      where: 'track_id = ?',
      whereArgs: [id],
    );
    logService.log('Deleting song: $id');
  }

  Future<void> removeFromPlaylist(int albumID) async {
    final dbService = GetIt.I<DatabaseService>();
    final songService = GetIt.I<SongService>();

    GetIt.I<LogService>().log('Removing song ($id) from album ($albumID)');

    final res = await dbService.db.query(
      TableNames.albumSongsTable,
      where: 'track_id = ? and album_id = ?',
      whereArgs: [id, albumID],
    );

    await dbService.db.delete(
      TableNames.albumSongsTable,
      where: 'track_id = ? and album_id = ?',
      whereArgs: [id, albumID],
    );

    await dbService.db.rawUpdate(
      'update ${TableNames.albumSongsTable} '
      'set track_order = track_order - 1 '
      'where album_id = ? and track_order > ?',
      [albumID, res.first['track_order']],
    );

    final otherAlbums = songService.albums.where((a) => a.id != 1 && a.id != albumID);
    final unknown = songService.albums.firstWhere((e) => e.id == 1);

    if (otherAlbums.any((a) => a.songs.contains(id)) || unknown.songs.contains(id)) {
      return;
    }
    unknown.songs.add(id);
    await unknown.update();
  }
}
