import 'package:music_hub/data/database/database.dart';
import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/utils.dart';

class AlbumService {
  final _logService = get<LogService>(),
      _database = get<MusicDatabase>(),
      _songService = get<SongService>();

  final List<Album> _albums = [];

  List<Album> get albums => List.from(_albums);

  Future<void> updateAlbumList() async {
    _logService.log('Updating album list');
    _albums.clear();
    final savedAlbums = (await _database.allAlbums).map(Album.fromData).toList();

    if (savedAlbums.isEmpty) {
      _logService.log("No album exists, creating default album 'Unknown'");
      _database.into(_database.album).insert(AlbumCompanion.insert(name: 'Unknown'));
      _albums.addAll((await _database.allAlbums).map(Album.fromData));
      return;
    }

    final allSongs = _songService.songs;

    for (final a in savedAlbums) {
      var s = await _database.albumSongs(a.id);
      final idList = s.map((e) => e.trackId).where((e) => _songService.hasSong(e));
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
