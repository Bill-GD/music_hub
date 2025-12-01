import 'dart:collection';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/song_service.dart';

class ArtistService {
  final _logService = GetIt.I<LogService>();
  // final _configService = GetIt.I<ConfigService>();
  // final _databaseService = GetIt.I<DatabaseService>();
  final _songService = GetIt.I<SongService>();

  Map<String, int> _artists = {};

  Map<String, int> get artists => Map.from(_artists);

  void updateArtistList() {
    _logService.log('Updating artist list');
    final allSongs = _songService.songs;

    final unsortedArtists = <String, int>{}
      ..addAll({
        for (final song in allSongs)
          song.artist: allSongs.where((s) => s.artist == song.artist).length,
      });
    _artists = SplayTreeMap.from(
      unsortedArtists,
      (key1, key2) => key1.toLowerCase().compareTo(key2.toLowerCase()),
    );
  }
}
