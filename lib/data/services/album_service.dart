import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';

class AlbumService {
  final _logService = GetIt.I<LogService>();
  final _databaseService = GetIt.I<DatabaseService>();
  final _songService = GetIt.I<SongService>();

  final List<Album> _albums = [];

  List<Album> get albums => List.from(_albums);

  Future<void> updateAlbumList() async {
    _logService.log('Updating album list');
    final savedAlbums = (await _databaseService.db.query(
      TableNames.albumTable,
    )).map(Album.fromJson).toList();
    _albums.clear();

    if (savedAlbums.isEmpty) {
      _logService.log("No album exists, creating default album 'Unknown'");
      final unknown = Album(name: 'Unknown', id: -1, timeAdded: DateTime.now())
        ..songs = _songService.idList
        ..insert();
      _albums.add(unknown);
      return;
    }

    final allSongs = _songService.songs;

    for (final a in savedAlbums) {
      var s = await _databaseService.db.query(
        TableNames.albumSongsTable,
        where: 'album_id = ?',
        whereArgs: [a.id],
        columns: ['track_order', 'track_id'],
        orderBy: 'track_order',
      );
      // LogHandler.log('$s');
      final idList = s.map((e) => e['track_id'] as int).where((e) => _songService.hasSong(e));
      for (final id in idList) {
        final addingSongIdx = allSongs.indexWhere((e) => e.id == id);
        if (addingSongIdx < 0 || allSongs[addingSongIdx].hasAlbum) continue;
        allSongs[addingSongIdx].hasAlbum = true;
      }
      a.songs.addAll(idList);
      _logService.log('Got album: id=${a.id}, n=${a.name}, l=${a.songs.length}');
    }

    savedAlbums.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final noAlbumSongs = allSongs.where((e) => !e.hasAlbum);
    final unknown = savedAlbums.firstWhereOrNull((a) => a.id == 1);
    if (unknown != null) {
      for (final e in noAlbumSongs) {
        // LogHandler.log('Adding song (${e.id}) to Unknown album');
        e.hasAlbum = true;
        unknown.songs.add(e.id);
      }
      unknown.update();
    }

    _albums.addAll(savedAlbums);
  }
}
