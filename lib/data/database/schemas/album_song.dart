import 'package:drift/drift.dart';

import 'package:music_hub/data/database/schemas/album.dart';
import 'package:music_hub/data/database/schemas/song.dart';
import 'package:music_hub/utils/constants.dart';

class AlbumSong extends Table {
  @override
  String get tableName => TableNames.albumSongsTable;

  IntColumn get trackOrder => integer().named('track_order')();

  IntColumn get trackId => integer().named('track_id').references(Song, #id)();

  IntColumn get albumId => integer().named('album_id').references(Album, #id)();

  @override
  Set<Column<Object>>? get primaryKey => {trackOrder, trackId, albumId};
}
