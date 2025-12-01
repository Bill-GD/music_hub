import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';

class SearchViewModel extends ChangeNotifier {
  final PlayerService playerService = GetIt.I();
  final SongService songService = GetIt.I();

  final List<String> filteredSongs = [];

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
