import 'package:drift/drift.dart';

mixin IncrementId on Table {
  IntColumn get id => integer().autoIncrement()();
}

mixin TimeAdded on Table {
  DateTimeColumn get timeAdded => dateTime().named('time_added').withDefault(currentDateAndTime)();
}