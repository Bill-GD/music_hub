import 'package:music_hub/data/models/lyric_item.dart';
import 'package:music_hub/utils/extensions.dart';

class SongLyric {
  final int songId;
  final String name, artist;
  final List<LyricItem> list;
  final String path;

  const SongLyric({
    required this.songId,
    required this.name,
    required this.artist,
    required this.path,
    required this.list,
  });

  SongLyric.from(SongLyric other)
    : songId = other.songId,
      name = other.name,
      artist = other.artist,
      list = List.from(other.list),
      path = other.path;

  @override
  String toString() {
    return 'id: $songId\n'
        'name: $name\n'
        'artist: $artist\n'
        'path: $path\n'
        '${list.map((e) => '${e.timestamp.toLyricTimestamp()} - ${e.line}').join('\n')}';
  }
}
