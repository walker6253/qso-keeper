import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import 'dart:io';

class AdifExporter {
  static String export(List<ContactRecord> contacts) {
    final buf = StringBuffer();
    buf.writeln('Ham Log ADIF Export');
    buf.writeln('<ADIF_VER:5>3.1.1');
    buf.writeln('<PROGRAMID:7>Ham Log');
    buf.writeln('<EOH>');
    final df = DateFormat('yyyyMMdd');
    final tf = DateFormat('HHmmss');
    for (final c in contacts) {
      final qsoDate = DateTime.fromMillisecondsSinceEpoch(c.dateEpochDay * 86400000, isUtc: true);
      final time = DateTime.fromMillisecondsSinceEpoch(c.createdAt, isUtc: true);
      _addField(buf, 'QSO_DATE', df.format(qsoDate));
      _addField(buf, 'TIME_ON', tf.format(time));
      _addField(buf, 'CALL', c.callsign);
      _addField(buf, 'FREQ', c.frequencyMHz.toString());
      _addField(buf, 'MODE', c.mode);
      _addField(buf, 'RST_SENT', c.rstSent);
      _addField(buf, 'RST_RCVD', c.rstReceived);
      if (c.powerTx.isNotEmpty) _addField(buf, 'TX_PWR', c.powerTx);
      if (c.powerRx.isNotEmpty) _addField(buf, 'RX_PWR', c.powerRx);
      if (c.notes.isNotEmpty) _addField(buf, 'COMMENT', c.notes);
      buf.writeln('<EOR>');
    }
    return buf.toString();
  }
  static void _addField(StringBuffer sb, String name, String value) {
    if (value.isNotEmpty) sb.writeln('<${name}:${value.length}>$value');
  }
}

