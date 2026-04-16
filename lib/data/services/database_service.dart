import 'dart:io';

import 'package:sqflite/sqflite.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/utils.dart';

class DatabaseService {
  final String _path;
  final LogService _logService = get();
  late final Database _db;

  Database get db => _db;

  DatabaseService._({required String path}) : _path = path;

  static Future<DatabaseService> create({required String path}) async {
    final service = DatabaseService._(path: path);
    await service._init();
    return service;
  }

  Future<void> _init() async {
    final dbFile = File(_path);
    if (!dbFile.existsSync()) dbFile.createSync(recursive: true);

    _db = await openDatabase(
      _path,
      version: 5,
      readOnly: false,
      onCreate: (db, _) async {
        await _createTables();
        _logService.log(
          'Song count: ${(await db.rawQuery('select count(*) count from music_track')).first['count']}',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        _logService.log('Upgrading database: $oldVersion -> $newVersion');
        await _createTables();
        await updateTables(oldVersion);
      },
      onOpen: (db) async {
        _logService.log('Database opened, version ${await db.getVersion()}');
      },
    );
  }

  Future<void> _createTables() async {
    _logService.log('Creating tables');
    await _db.execute(
      'create table if not exists ${TableNames.songTable} ('
      'id integer primary key,'
      'path text not null,' // the path is relative to /storage/emulated/0/Download, basically the file name only
      'name text not null,'
      'artist text not null,'
      'time_listened integer default 0,'
      'lyric_path text not null default "",'
      'image_path text not null default "",'
      'time_added datetime not null,'
      'deleted boolean not null check (deleted in (0, 1)) default 0'
      ');',
    );
    await _db.execute(
      'create table if not exists ${TableNames.albumTable} ('
      'id integer primary key,'
      'name text not null,'
      'image_path text not null default "",'
      'time_added datetime not null'
      ');',
    );
    await _db.execute(
      'create table if not exists ${TableNames.albumSongsTable} ('
      'track_order integer not null,'
      'track_id integer not null,'
      'album_id integer not null,'
      'primary key (track_order, track_id, album_id),'
      'foreign key (track_id) references music_track (id),'
      'foreign key (album_id) references album (id)'
      ');',
    );
    await _db.execute(
      'create table if not exists ${TableNames.playlistTable} ('
      'id integer primary key,'
      'list_name text not null,'
      'song_id integer not null,'
      'is_current integer not null default 0'
      ');',
    );
  }

  Future<void> updateTables(int oldVersion) async {
    if (oldVersion < 3) {
      _logService.log(
        "Adding 'lyric_path' to ${TableNames.songTable}, renaming columns to snake_case",
      );
      await db.execute(
        'alter table ${TableNames.songTable} add column lyric_path text not null default "";',
      );
      await db.execute(
        'alter table ${TableNames.songTable} rename column "timeAdded" to "time_added";',
      );
      await db.execute(
        'alter table ${TableNames.songTable} rename column "timeListened" to "time_listened";',
      );
      await db.execute(
        'alter table ${TableNames.albumTable} rename column "timeAdded" to "time_added";',
      );
    }
    if (oldVersion < 4) {
      _logService.log('Adding image_path column to ${TableNames.songTable}');
      await db.execute(
        'alter table ${TableNames.songTable} add column image_path text not null default "";',
      );
      await db.execute(
        'alter table ${TableNames.albumTable} add column image_path text not null default "";',
      );
    }
    if (oldVersion < 5) {
      _logService.log('Adding deleted flag to ${TableNames.songTable}');
      await _db.execute(
        'alter table ${TableNames.songTable} add column deleted boolean not null check (deleted in (0, 1)) default 0;',
      );
    }
  }

  Future<void> clearAllData() async {
    _logService.log(
      "This deletes all saved data. If used alone, it won't be recoverable.",
      .warn,
    );
    await _db.delete(TableNames.songTable);
    await _db.delete(TableNames.albumTable);
    await _db.delete(TableNames.albumSongsTable);
  }
}
