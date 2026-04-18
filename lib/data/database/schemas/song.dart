import 'package:drift/drift.dart';

import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/mixins.dart';

class Song extends Table with IncrementId, TimeAdded {
  @override
  String get tableName => TableNames.songTable;

  TextColumn get path => text()();

  TextColumn get name => text()();

  TextColumn get artist => text()();

  IntColumn get timeListened =>
      integer().named('time_listened').withDefault(const Constant(0))();

  TextColumn get lyricPath =>
      text().named('lyric_path').withDefault(const Constant(''))();

  TextColumn get imagePath =>
      text().named('image_path').withDefault(const Constant(''))();

  BoolColumn get deleted =>
      boolean().withDefault(const Constant(false)).check(deleted.isIn([true, false]))();
}
