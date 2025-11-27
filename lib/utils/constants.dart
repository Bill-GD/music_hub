import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Constants {
  static const appName = 'Music Hub';
  static final appVersion = dotenv.env['VERSION'] ?? '0.0.0';
  static final isDev = appVersion.contains('_dev_');
  static final devBuild = appVersion.split('_').last;
  static final githubToken = dotenv.env['GITHUB_TOKEN'] ?? '';
}

abstract final class TableNames {
  static const songTable = 'music_track';
  static const albumTable = 'album';
  static const albumSongsTable = 'album_tracks';
  static const playlistTable = 'playlist';
}

abstract final class Paths {
  static const backupPath = '/storage/emulated/0/Android/music_hub_backup/';
  static const downloadPath = '/storage/emulated/0/Download/';
  static const lyricPath = '/storage/emulated/0/Lyrics/';

  static late final String storagePath;
  static late final String jsonPath;
  static late final String dbPath;
  static late final String logPath;
}
