import 'dart:async';

import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/utils/globals/music_track.dart';

class Globals {
  /// List of all songs, persistent.
  static List<MusicTrack> allSongs = [];

  /// List of name and song count of artists.
  static Map<String, int> artists = {};

  /// List of name and song count of albums.
  static List<Album> albums = [];

  /// Does the minimized player shows up?
  static bool showMinimizedPlayer = false;
  static bool setDuplicate = false;

  /// ID of the currently selected/playing song.
  static int currentSongID = -1;
  static String? savedPlaylistName;

  static final lyricChangedController = StreamController<void>.broadcast();
}
