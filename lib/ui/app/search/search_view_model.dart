import 'package:flutter/foundation.dart';

import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';

class SearchViewModel extends ChangeNotifier {
  final PlayerService playerService;
  final SongService songService;

  final List<String> filteredSongs = [];

  SearchViewModel({required this.playerService, required this.songService});

  void searchSongs(String keyword) {
    filteredSongs.clear();
    filteredSongs.addAll(
      songService.allSongs
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
