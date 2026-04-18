import 'package:drift/drift.dart';

import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/mixins.dart';

class Album extends Table with IncrementId, TimeAdded {
  @override
  String get tableName => TableNames.albumTable;

  TextColumn get name => text()();

  TextColumn get imagePath =>
      text().named('image_path').withDefault(const Constant(''))();
}
