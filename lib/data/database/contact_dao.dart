import 'package:drift/drift.dart';
import 'tables.dart';
import 'app_database.dart';
part 'contact_dao.g.dart';

@DriftAccessor(tables: [ContactRecords])
class ContactDao extends DatabaseAccessor<AppDatabase> with _$ContactDaoMixin {
  ContactDao(super.db);

  Future<List<ContactRecord>> getContactsByDate(int dateEpochDay) =>
      (select(contactRecords)..where((t) => t.dateEpochDay.equals(dateEpochDay))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<List<ContactRecord>> getAllContacts() =>
      (select(contactRecords)..orderBy([(t) => OrderingTerm.desc(t.dateEpochDay), (t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<int> getContactCountByDate(int dateEpochDay) =>
      (selectOnly(contactRecords)..addColumns([contactRecords.id.count()])
        ..where(contactRecords.dateEpochDay.equals(dateEpochDay)))
        .map((r) => r.read(contactRecords.id.count()) ?? 0).getSingle();

  Future<List<int>> getAllDates() =>
      (selectOnly(contactRecords)..addColumns([contactRecords.dateEpochDay])
        ..where(contactRecords.dateEpochDay.isNotNull())
        ..orderBy([OrderingTerm.desc(contactRecords.dateEpochDay)])
        ..distinct)
        .map((r) => r.read(contactRecords.dateEpochDay)!).get();

  Future<List<DateCount>> getAllDatesWithCount() =>
      (selectOnly(contactRecords)..addColumns([contactRecords.dateEpochDay, contactRecords.id.count()])
        ..groupBy([contactRecords.dateEpochDay])
        ..orderBy([OrderingTerm.desc(contactRecords.dateEpochDay)]))
        .map((r) => DateCount(dateEpochDay: r.read(contactRecords.dateEpochDay)!, count: r.read(contactRecords.id.count()) ?? 0)).get();

  Future<int> getTotalCount() => (selectOnly(contactRecords)..addColumns([contactRecords.id.count()])).map((r) => r.read(contactRecords.id.count()) ?? 0).getSingle();

  Future<List<String>> getDistinctCallsigns() =>
      (selectOnly(contactRecords)..addColumns([contactRecords.callsign])
        ..where(contactRecords.callsign.isNotNull())
        ..orderBy([OrderingTerm.asc(contactRecords.callsign)])
        ..distinct)
        .map((r) => r.read(contactRecords.callsign)!).get();

  Future<List<String>> searchCallsigns(String prefix) =>
      customSelect('SELECT DISTINCT callsign FROM contact_records WHERE callsign LIKE ?1 ORDER BY callsign ASC LIMIT 8',
        variables: [Variable.withString('$prefix%')])
        .map((r) => r.read<String>('callsign')).get();

  Future<LastContactInfo?> getLastContactByCallsign(String callsign) =>
      customSelect('SELECT DISTINCT callsign, frequency_m_hz AS frequencyMHz, mode FROM contact_records WHERE callsign = ?1 ORDER BY created_at DESC LIMIT 1',
        variables: [Variable.withString(callsign)])
        .map((r) => LastContactInfo(
          callsign: r.read<String>('callsign'),
          frequencyMHz: r.read<double>('frequencyMHz') ?? 0,
          mode: r.read<String>('mode') ?? '')).getSingleOrNull();

  Future<List<ContactRecord>> getContactsByCallsign(String callsign) =>
      (select(contactRecords)..where((t) => t.callsign.equals(callsign))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<List<DateCount>> getDateCountsInRange(int start, int end) =>
      customSelect('SELECT date_epoch_day AS dateEpochDay, COUNT(*) as count FROM contact_records WHERE date_epoch_day >= ?1 AND date_epoch_day <= ?2 GROUP BY date_epoch_day ORDER BY date_epoch_day ASC',
        variables: [Variable.withInt(start), Variable.withInt(end)])
        .map((r) => DateCount(dateEpochDay: r.read<int>('dateEpochDay')!, count: r.read<int>('count') ?? 0)).get();

  Future<List<ModeCount>> getModeDistribution() =>
      customSelect("SELECT mode, COUNT(*) as count FROM contact_records WHERE mode IS NOT NULL AND mode != '' GROUP BY mode ORDER BY count DESC")
        .map((r) => ModeCount(mode: r.read<String>('mode')!, count: r.read<int>('count') ?? 0)).get();

  Future<int?> getFirstContactDate() =>
      (selectOnly(contactRecords)..addColumns([contactRecords.dateEpochDay.min()]))
        .map((r) => r.read(contactRecords.dateEpochDay.min())).getSingleOrNull();

  Future<int?> getLastContactDate() =>
      (selectOnly(contactRecords)..addColumns([contactRecords.dateEpochDay.max()]))
        .map((r) => r.read(contactRecords.dateEpochDay.max())).getSingleOrNull();

  Future<int> getDistinctCallsignCount() =>
      customSelect("SELECT COUNT(DISTINCT callsign) as cnt FROM contact_records WHERE callsign IS NOT NULL AND callsign != ''")
        .map((r) => r.read<int>('cnt') ?? 0).getSingle();

  Future<int> getActiveDaysCount() =>
      customSelect('SELECT COUNT(DISTINCT date_epoch_day) as cnt FROM contact_records')
        .map((r) => r.read<int>('cnt') ?? 0).getSingle();

  Future<int> insertContact(ContactRecordsCompanion c) => into(contactRecords).insert(c);
  Future<int> deleteContact(int id) => (delete(contactRecords)..where((t) => t.id.equals(id))).go();
  Future<bool> updateContact(ContactRecord c) => update(contactRecords).replace(c);
}

class DateCount { final int dateEpochDay; final int count; DateCount({required this.dateEpochDay, required this.count}); }
class ModeCount { final String mode; final int count; ModeCount({required this.mode, required this.count}); }
class LastContactInfo { final String callsign; final double frequencyMHz; final String mode; LastContactInfo({required this.callsign, required this.frequencyMHz, required this.mode}); }
