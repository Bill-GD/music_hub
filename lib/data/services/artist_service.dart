import 'dart:collection';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/utils.dart';

class ArtistService {
  final _logService = get<LogService>(), _songService = get<SongService>();

  Map<String, int> _artists = {};

  Map<String, int> get artists => Map.from(_artists);

  void updateArtistList({void Function(String text)? updateToast}) {
    _logService.log('Updating artist list');
    final allSongs = _songService.songs;

    final unsortedArtists = <String, int>{};
    final artists = allSongs.map((s) => s.artist).toSet();

    for (int i = 0; i < artists.length; i++) {
      updateToast?.call('Updating artist list: ${i + 1}/${artists.length}');
      final artist = artists.elementAt(i);
      unsortedArtists.putIfAbsent(
        artist,
        () => allSongs.where((s) => s.artist == artist).length,
      );
    }

    _artists = SplayTreeMap.from(
      unsortedArtists,
      (key1, key2) => key1.toLowerCase().compareTo(key2.toLowerCase()),
    );
  }
}
