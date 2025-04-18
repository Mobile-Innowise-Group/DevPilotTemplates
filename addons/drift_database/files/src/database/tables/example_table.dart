import 'package:drift/drift.dart';

class ExampleTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().unique()();
}
