import 'package:flutter/foundation.dart';

import 'package:music_hub/data/services/playlist_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/utils.dart';

class SearchViewModel extends ChangeNotifier {
  final playlistService = get<PlaylistService>(), songService = get<SongService>();

  final List<String> filteredSongs = [];

  void searchSongs(String keyword) {
    filteredSongs.clear();
    filteredSongs.addAll(
      songService.songs
          .where(
            (song) =>
                song.name.toLowerCase().contains(keyword.toLowerCase()) ||
                song.artist.toLowerCase().contains(keyword.toLowerCase()),
          )
          .map((e) => e.path),
    );
    notifyListeners();
  }
}
