import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/utils.dart';

class Album {
  int id;
  String name;
  DateTime timeAdded;
  String imagePath;
  List<int> songs = [];

  Album({required this.name, this.id = -1, this.imagePath = '', required this.timeAdded});

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

  Future<void> insert() async {
    final logService = get<LogService>();
    final dbService = get<DatabaseService>();

    if (id >= 0) {
      return logService.log('Trying to insert duplicate album id ($id)', .error);
    }
    id = await dbService.db.insert(TableNames.albumTable, toJson()..remove('id'));
    logService.log('Inserted album -> new id: $id');
    for (final i in range(0, songs.length - 1)) {
      await dbService.db.insert(TableNames.albumSongsTable, {
        'track_order': i,
        'track_id': songs[i],
        'album_id': id,
      });
    }
  }

  Future<void> update() async {
    final logService = get<LogService>();
    final dbService = get<DatabaseService>();

    if (id < 0) {
      return logService.log('Trying to update album id -1', .error);
    }
    logService.log('Update album ($id)');

    await dbService.db.update(
      TableNames.albumTable,
      toJson(),
      where: 'id = ?',
      whereArgs: [id],
    );

    await dbService.db.delete(
      TableNames.albumSongsTable,
      where: 'album_id = ?',
      whereArgs: [id],
    );

    for (final i in range(0, songs.length - 1)) {
      await dbService.db.insert(TableNames.albumSongsTable, {
        'track_order': i,
        'album_id': id,
        'track_id': songs[i],
      });
    }
  }

  Future<void> delete() async {
    final logService = get<LogService>();
    final dbService = get<DatabaseService>();

    if (id < 0) {
      return logService.log('Trying to delete album id -1', .error);
    }
    logService.log('Deleting album ($id)');
    await dbService.db.delete(TableNames.albumTable, where: 'id = ?', whereArgs: [id]);
    await dbService.db.delete(
      TableNames.albumSongsTable,
      where: 'album_id = ?',
      whereArgs: [id],
    );

    final otherAlbums = get<AlbumService>().albums.where((a) => a.id != 1 && a.id != id);
    final unknown = get<AlbumService>().albums.firstWhere((e) => e.id == 1);

    for (final s in songs) {
      if (otherAlbums.any((a) => a.songs.contains(s)) || unknown.songs.contains(s)) {
        continue;
      }
      unknown.songs.add(s);
    }
    await unknown.update();
  }
}
