import 'package:music_hub/data/services/player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/playlist_service.dart';
import 'package:music_hub/utils/utils.dart';

/// All user configurations, expose to user in setting page.
class ConfigService {
  final LogService _logService = get();

  /// Whether the app should backup data on launch.
  bool backupOnLaunch = false;

  /// Should filtering out all short files.
  bool enableSongFiltering = true;

  /// Filters out all files shorter than this, default `30` seconds.
  int lengthLimitMilliseconds = 30000;

  /// Should the player start when choosing a new song, default `true`.
  bool autoPlayNewSong = true;

  /// The delay between song changes, default `0` milliseconds. Range `[0, 500]`.
  int delayMilliseconds = 0;

  /// Should the lyric type page show current lyric, default `true`.
  bool appendLyric = false;

  /// The base volume of the player, default `1`. Range `[0, 1]`.
  double volume = 1;

  /// How many backups to keep. Default `5`.
  int backupCount = 5;

  /// Current sorting order of the song list, default [SortOptions.name].
  SortOptions currentSortOption = .name;

  String getSortOptionString() {
    return switch (currentSortOption) {
      .id => 'ID',
      .name => 'Name',
      .mostPlayed => 'Most played',
      .recentlyAdded => 'Recently added',
    };
  }

  Future<void> saveConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final playlistService = get<PlaylistService>();

    await prefs.setBool('backupOnLaunch', backupOnLaunch);
    await prefs.setBool('enableSongFiltering', enableSongFiltering);
    await prefs.setInt('lengthLimitSecond', (lengthLimitMilliseconds / 1000).round());
    await prefs.setBool('autoPlayNewSong', autoPlayNewSong);
    await prefs.setInt('delayMilliseconds', delayMilliseconds);
    await prefs.setBool('appendLyric', appendLyric);
    await prefs.setDouble('volume', volume);
    await prefs.setInt('backupCount', backupCount);
    await prefs.setString('currentSortOption', currentSortOption.name);
    await prefs.setBool('isShuffled', playlistService.isShuffled);
    await prefs.setString('repeatMode', playlistService.repeatMode.name);
    _logService.log('Config saved');
  }

  Future<void> loadConfig() async {
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

    get<PlayerService>().loadConfig();
    get<PlaylistService>().loadConfig(
      prefs.getBool('isShuffled'),
      prefs.getString('repeatMode'),
    );
    _logService.log('Config loaded');
  }
}

enum SortOptions { id, name, mostPlayed, recentlyAdded }
