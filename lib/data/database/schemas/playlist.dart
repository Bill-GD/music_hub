import 'package:drift/drift.dart';

import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/mixins.dart';

class Playlist extends Table with IncrementId {
  @override
  String get tableName => TableNames.playlistTable;

  TextColumn get listName => text().named('list_name')();

  IntColumn get songId => integer().named('song_id')();

  BoolColumn get isCurrent =>
      boolean().named('is_current').withDefault(const Constant(false))();
}
