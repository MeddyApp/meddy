import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase(super.executor);
  // AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // static LazyDatabase _openConnection() {
  //   // the LazyDatabase util lets us find the right location for the file async.
  //   return LazyDatabase(() async {
  //     final dbFolder = await getApplicationDocumentsDirectory();
  //     final file = File(p.join(dbFolder.path, 'db.sqlite'));

  //     return NativeDatabase.createInBackground(file);
  //   });
  // }
}
