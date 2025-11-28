import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart' show Paths, TableNames;

class BackupService {
  final ConfigService _configService = GetIt.I();
  final LogService _logService = GetIt.I();
  final DatabaseService _databaseService = GetIt.I();

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
      'songs': await _databaseService.db.query(TableNames.songTable),
      'albums': await _databaseService.db.query(TableNames.albumTable),
      'album_songs': await _databaseService.db.query(TableNames.albumSongsTable),
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

    if (!File(Paths.dbPath).existsSync()) {
      _logService.log('Database files should exists after app launched.', .error);
      // DatabaseHandler.init(); // may init again, will see
    }

    final backupContent = bu
        .readAsStringSync()
        .replaceAll('timeAdded', 'time_added')
        .replaceAll('timeListened', 'time_listened');

    final json = jsonDecode(backupContent) as Map<String, dynamic>;

    await _databaseService.clearAllData();
    for (final o in json['songs']!) {
      await _databaseService.db.insert(TableNames.songTable, o);
    }
    for (final o in json['albums']!) {
      await _databaseService.db.insert(TableNames.albumTable, o);
    }
    for (final o in json['album_songs']!) {
      await _databaseService.db.insert(TableNames.albumSongsTable, o);
    }
  }
}
