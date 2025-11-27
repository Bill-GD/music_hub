import 'dart:convert';
import 'dart:io';

import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/globals/globals.dart';

class BackupService {
  static void init() {
    final buDir = Directory(Globals.backupPath);
    if (!buDir.existsSync()) buDir.createSync();
  }

  static void _cleanUpBackup() {
    final backupFiles = getBackups();
    if (backupFiles.length <= ConfigService.backupCount) return;

    LogService.log('Cleaning up backup files');
    while (backupFiles.length > ConfigService.backupCount) {
      final f = backupFiles.removeLast();
      LogService.log('Deleting backup file: ${f.path}');
      f.deleteSync();
    }
  }

  static Future<void> backupData() async {
    File bu =
        File('${Globals.backupPath}${Uri.encodeFull(DateTime.now().toIso8601String().replaceAll(':', "-"))}.json');
    if (bu.existsSync()) {
      LogService.log('Backup file with same name already exists, deleting');
      bu.deleteSync();
    } else {
      bu.createSync();
    }

    LogService.log('Backing up data to: ${bu.path}');
    final data = {
      'songs': await DatabaseService.db.query(Globals.songTable),
      'albums': await DatabaseService.db.query(Globals.albumTable),
      'album_songs': await DatabaseService.db.query(Globals.albumSongsTable),
    };

    bu.writeAsStringSync(jsonEncode(data));
    _cleanUpBackup();
  }

  static List<FileSystemEntity> getBackups() {
    final backupFiles = Directory(Globals.backupPath) //
        .listSync()
        .where((f) => f is File && f.path.endsWith('.json'))
        .toList();
    backupFiles.sort((a, b) => b.statSync().changed.compareTo(a.statSync().changed));
    return backupFiles;
  }

  static Future<void> recoverBackup(File bu) async {
    // final bu = getBackups().last;
    LogService.log('Recovering backup data from: ${bu.path}');

    if (!File(Globals.dbPath).existsSync()) {
      LogService.log('Database files should exists after app launched.', LogLevel.error);
      // DatabaseHandler.init(); // may init again, will see
    }

    final backupContent = bu //
        .readAsStringSync()
        .replaceAll('timeAdded', 'time_added')
        .replaceAll('timeListened', 'time_listened');

    final json = jsonDecode(backupContent) as Map<String, dynamic>;

    await DatabaseService.clearAllData();
    for (final o in json['songs']!) {
      await DatabaseService.db.insert(Globals.songTable, o);
    }
    for (final o in json['albums']!) {
      await DatabaseService.db.insert(Globals.albumTable, o);
    }
    for (final o in json['album_songs']!) {
      await DatabaseService.db.insert(Globals.albumSongsTable, o);
    }
  }
}
