import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import 'dart:io';

class AdifImporter {
  static List<ContactRecord> parse(String content) {
    final records = <ContactRecord>[];
    final lines = content.split('\n');
    bool inHeader = true; final fields = <String, String>{};
    for (final line in lines) {
      final t = line.trim(); if (t.isEmpty) continue;
      if (inHeader) { if (t.toUpperCase().contains('<EOH>')) inHeader = false; continue; }
      if (t.toUpperCase().contains('<EOR>')) { final c = _buildContact(fields); if (c != null) records.add(c); fields.clear(); continue; }
      _parseFields(t, fields);
    }
    return records;
  }
  static void _parseFields(String line, Map<String, String> fields) {
    int i = 0;
    while (i < line.length) {
      if (line[i] != '<') { i++; continue; }
      final end = line.indexOf('>', i); if (end == -1) break;
      final tag = line.substring(i + 1, end); final ci = tag.indexOf(':'); if (ci == -1) { i = end + 1; continue; }
      final name = tag.substring(0, ci).toUpperCase().trim();
      final len = int.tryParse(tag.substring(ci + 1).trim()) ?? 0;
      final vs = end + 1; final ve = (vs + len).clamp(0, line.length);
      if (name.isNotEmpty) fields[name] = line.substring(vs, ve).trim();
      i = ve;
    }
  }
  static ContactRecord? _buildContact(Map<String, String> f) {
    final call = f['CALL'] ?? ''; if (call.isEmpty) return null;
    int? epochDay;
    for (final fmt in ['yyyyMMdd', 'yyyy-MM-dd', 'yyyy/MM/dd']) {
      try { epochDay = DateFormat(fmt).parse(f['QSO_DATE'] ?? f['QSO_DATE_OFF'] ?? '').millisecondsSinceEpoch ~/ 86400000; break; } catch (_) {}
    }
    epochDay ??= DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final freq = double.tryParse(f['FREQ'] ?? f['FREQ_RX'] ?? '0') ?? 0;
    return ContactRecord(id: 0, dateEpochDay: epochDay, callsign: call.toUpperCase().trim(),
      frequencyMHz: freq, mode: (f['MODE'] ?? '').trim(), rstSent: (f['RST_SENT'] ?? f['RST_S'] ?? '').trim(),
      rstReceived: (f['RST_RCVD'] ?? f['RST_R'] ?? '').trim(), powerTx: (f['TX_PWR'] ?? '').trim(),
      powerRx: (f['RX_PWR'] ?? '').trim(), notes: (f['COMMENT'] ?? f['NOTES'] ?? f['QSLMSG'] ?? '').trim(), createdAt: DateTime.now().millisecondsSinceEpoch);
  }
}

