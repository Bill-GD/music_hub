import 'package:shared_preferences/shared_preferences.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/globals/globals.dart';

/// All user configurations, expose to user in setting page.
class ConfigService {
  /// Whether the app should backup data on launch.
  static bool backupOnLaunch = false;

  /// Should filtering out all short files.
  static bool enableSongFiltering = true;

  /// Filters out all files shorter than this, default `30` seconds.
  static int lengthLimitMilliseconds = 30000;

  /// Should the player start when choosing a new song, default `true`.
  static bool autoPlayNewSong = true;

  /// The delay between song changes, default `0` milliseconds. Range `[0, 500]`.
  static int delayMilliseconds = 0;

  /// Should the lyric type page show current lyric, default `true`.
  static bool appendLyric = false;

  /// The base volume of the player, default `1`. Range `[0, 1]`.
  static double volume = 1;

  /// How many backups to keep. Default `5`.
  static int backupCount = 5;

  /// Current sorting order of the song list, default [SortOptions.name].
  static SortOptions currentSortOption = .name;

  static String getSortOptionString() {
    switch (currentSortOption) {
      case .id:
        return 'ID';
      case .name:
        return 'Name';
      case .mostPlayed:
        return 'Most played';
      case .recentlyAdded:
        return 'Recently added';
    }
  }

  static Future<void> saveConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('backupOnLaunch', backupOnLaunch);
    await prefs.setBool('enableSongFiltering', enableSongFiltering);
    await prefs.setInt('lengthLimitSecond', (lengthLimitMilliseconds / 1000).round());
    await prefs.setBool('autoPlayNewSong', autoPlayNewSong);
    await prefs.setInt('delayMilliseconds', delayMilliseconds);
    await prefs.setBool('appendLyric', appendLyric);
    await prefs.setDouble('volume', volume);
    await prefs.setInt('backupCount', backupCount);
    await prefs.setString('currentSortOption', currentSortOption.name);
    await prefs.setBool('isShuffled', Globals.audioHandler.isShuffled);
    await prefs.setString('repeatMode', Globals.audioHandler.repeatMode.name);
    LogService.log('Config saved');
  }

  static Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    backupOnLaunch = prefs.getBool('backupOnLaunch') ?? false;
    enableSongFiltering = prefs.getBool('enableSongFiltering') ?? true;
    lengthLimitMilliseconds = (prefs.getInt('lengthLimitSecond') ?? 30) * 1000;
    autoPlayNewSong = prefs.getBool('autoPlayNewSong') ?? true;
    delayMilliseconds = prefs.getInt('delayMilliseconds') ?? 0;
    appendLyric = prefs.getBool('appendLyric') ?? false;
    volume = (prefs.getDouble('volume') ?? 1).clamp(0, 1);
    backupCount = prefs.getInt('backupCount') ?? 5;

    currentSortOption = .values.firstWhere(
      (option) => option.name == prefs.getString('currentSortOption'),
      orElse: () => .name,
    );

    Globals.audioHandler.loadConfig(
      prefs.getBool('isShuffled'),
      prefs.getString('repeatMode'),
    );
    LogService.log('Config loaded');
  }
}

enum SortOptions { id, name, mostPlayed, recentlyAdded }
