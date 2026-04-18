import 'dart:convert';
import 'dart:io';

import 'package:music_hub/data/database/database.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/utils.dart';

class BackupService {
  final _configService = get<ConfigService>(),
      _logService = get<LogService>(),
      _database = get<MusicDatabase>();

  BackupService() {
    final buDir = Directory(Paths.backupPath);
    if (!buDir.existsSync()) buDir.createSync();
  }

  void _cleanUpBackup() {
    final backupFiles = getBackups();
    if (backupFiles.length <= _configService.backupCount) return;

    _logService.log('Cleaning up backup files');
    while (backupFiles.length > _configService.backupCount) {
      final f = backupFiles.removeLast();
      _logService.log('Deleting backup file: ${f.path}');
      f.deleteSync();
    }
  }

  Future<void> backupData() async {
    File bu = File(
      '${Paths.backupPath}'
      '${Uri.encodeFull(DateTime.now().toIso8601String().replaceAll(':', "-"))}'
      '.json',
    );
    if (bu.existsSync()) {
      _logService.log('Backup file with same name already exists, deleting');
      bu.deleteSync();
    } else {
      bu.createSync();
    }

    _logService.log('Backing up data to: ${bu.path}');
    final data = {
      'songs': await _database.allSongs,
      'albums': await _database.allAlbums,
      'album_songs': await _database.allAlbumSongs,
    };

    bu.writeAsStringSync(jsonEncode(data));
    _cleanUpBackup();
  }

  List<FileSystemEntity> getBackups() {
    final backupFiles = Directory(
      Paths.backupPath,
    ).listSync().where((f) => f is File && f.path.endsWith('.json')).toList();
    backupFiles.sort((a, b) => b.statSync().changed.compareTo(a.statSync().changed));
    return backupFiles;
  }

  Future<void> recoverBackup(File bu) async {
    _logService.log('Recovering backup data from: ${bu.path}');

    if (!File(Paths.oldDbPath).existsSync()) {
      _logService.log('Database files should exists after app launched.', .error);
      // DatabaseHandler.init(); // may init again, will see
    }

    final backupContent = bu
        .readAsStringSync()
        .replaceAll('timeAdded', 'time_added')
        .replaceAll('timeListened', 'time_listened');

    final json = jsonDecode(backupContent) as Map<String, dynamic>;

    await _database.clearAllData();
    await _database.batch((batch) {
      batch.insertAll(
        _database.song,
        (json['songs']! as Iterable<Map<String, dynamic>>).map(SongData.fromJson),
      );
      batch.insertAll(
        _database.album,
        (json['albums']! as Iterable<Map<String, dynamic>>).map(AlbumData.fromJson),
      );
      batch.insertAll(
        _database.albumSong,
        (json['album_songs']! as Iterable<Map<String, dynamic>>).map(
          AlbumSongData.fromJson,
        ),
      );
    });
  }
}
