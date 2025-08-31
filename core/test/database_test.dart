import 'package:test/test.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:meddy_core/src/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('insert and fetch medication and dose_event', () async {
    // Insert a medication
    final medId = await db
        .into(db.medication)
        .insert(
          MedicationCompanion(
            name: const d.Value('Aspirin'),
            form: const d.Value('Pill'),
            strengthAmount: const d.Value(200),
            strengthUnit: const d.Value('mg'),
            shape: const d.Value('round'),
            color: const d.Value('#FFFFFF'),
            active: const d.Value(true),
          ),
        );

    // Insert a dose_event
    final doseId = await db
        .into(db.doseEvent)
        .insert(
          DoseEventCompanion(
            medicationId: d.Value(medId),
            quantity: const d.Value(1),
            scheduledAt: const d.Value(1630454400), // example epoch
            scheduledTz: const d.Value(0),
            takenAt: const d.Value(1630458000),
            takenTz: const d.Value(0),
            recordedAt: const d.Value(1630458100),
            recordedTz: const d.Value(0),
            notes: const d.Value('Taken as scheduled'),
          ),
        );

    // Fetch and check medication
    final med = await (db.select(
      db.medication,
    )..where((tbl) => tbl.id.equals(medId))).getSingleOrNull();
    expect(med, isNotNull);
    expect(med!.name, 'Aspirin');

    // Fetch and check dose_event
    final dose = await (db.select(
      db.doseEvent,
    )..where((tbl) => tbl.id.equals(doseId))).getSingleOrNull();
    expect(dose, isNotNull);
    expect(dose!.medicationId, medId);
    expect(dose.notes, 'Taken as scheduled');
  });
}
