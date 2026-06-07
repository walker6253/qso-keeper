import 'dart:convert';
import 'package:dio/dio.dart';
import '../data/database/app_database.dart';
import 'dart:io';

class StationInfo { final String id; final String name; const StationInfo(this.id, this.name);

  static List<StationInfo> fromJsonList(String json) {
    try {
      final List<dynamic> arr = jsonDecode(json);
      return arr.map((o) => StationInfo(o['stationId']?.toString()??'', o['stationName']?.toString()??'')).toList();
    } catch (_) { return []; }
  }

  static String toJsonList(List<StationInfo> list) {
    return jsonEncode(list.map((s) => {'stationId': s.id, 'stationName': s.name}).toList());
  }
}
class SyncResult { final int success; final int failed; final List<String> errors; const SyncResult({this.success=0, this.failed=0, this.errors=const[]}); }

class CloudlogSyncService {
  final Dio _dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 15), receiveTimeout: Duration(seconds: 15)));

  static String _freqToBand(double mhz) {
    if (mhz >= 1.8 && mhz < 2.0) return '160m'; if (mhz >= 3.5 && mhz < 4.0) return '80m';
    if (mhz >= 5.0 && mhz < 5.5) return '60m'; if (mhz >= 7.0 && mhz < 7.3) return '40m';
    if (mhz >= 10.0 && mhz < 10.2) return '30m'; if (mhz >= 14.0 && mhz < 14.35) return '20m';
    if (mhz >= 18.0 && mhz < 18.2) return '17m'; if (mhz >= 21.0 && mhz < 21.45) return '15m';
    if (mhz >= 24.89 && mhz < 24.99) return '12m'; if (mhz >= 28.0 && mhz < 29.7) return '10m';
    if (mhz >= 50.0 && mhz < 54.0) return '6m'; if (mhz >= 144.0 && mhz < 148.0) return '2m';
    if (mhz >= 430.0 && mhz < 450.0) return '70cm'; return '';
  }

  String _adifTag(String tag, String val) => val.isEmpty ? '' : '<$tag:${val.length}>$val';

  Future<SyncResult> syncContacts({required String baseUrl, required String apiKey, required List<ContactRecord> contacts, String callsign='', String gridSquare='', String stationProfileId='1'}) async {
    int success = 0, failed = 0; final errors = <String>[];
    final url = baseUrl.trimRight().replaceAll(RegExp(r'/+$'), '') + '/index.php/api/qso';
    for (final c in contacts) {
      try {
        final band = _freqToBand(c.frequencyMHz); final adif = StringBuffer();
        adif.write(_adifTag('CALL', c.callsign.toUpperCase().trim()));
        if (band.isNotEmpty) adif.write(_adifTag('BAND', band));
        adif.write(_adifTag('MODE', c.mode.toUpperCase().trim()));
        final d = DateTime.fromMillisecondsSinceEpoch(c.createdAt, isUtc: true);
        adif.write(_adifTag('QSO_DATE','${d.year}${d.month.toString().padLeft(2,'0')}${d.day.toString().padLeft(2,'0')}'));
        adif.write(_adifTag('TIME_ON','${d.hour.toString().padLeft(2,'0')}${d.minute.toString().padLeft(2,'0')}${d.second.toString().padLeft(2,'0')}'));
        adif.write(_adifTag('RST_SENT', c.rstSent.trim())); adif.write(_adifTag('RST_RCVD', c.rstReceived.trim()));
        adif.write(_adifTag('FREQ', c.frequencyMHz.toString()));
        if (c.powerTx.isNotEmpty) adif.write(_adifTag('TX_PWR', c.powerTx.replaceAll(RegExp(r'[Ww]$'), '').trim()));
        if (c.powerRx.isNotEmpty) adif.write(_adifTag('RX_PWR', c.powerRx.replaceAll(RegExp(r'[Ww]$'), '').trim()));
        if (c.notes.isNotEmpty) adif.write(_adifTag('QSLMSG', c.notes.trim()));
        if (gridSquare.isNotEmpty) adif.write(_adifTag('GRIDSQUARE', gridSquare));
        if (callsign.isNotEmpty) adif.write(_adifTag('STATION_CALLSIGN', callsign.toUpperCase().trim()));
        adif.write('<EOR>');
        final resp = await _dio.post(url,
          data: jsonEncode({'key': apiKey, 'station_profile_id': stationProfileId, 'type': 'adif', 'string': adif.toString()}),
          options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, validateStatus: (status) => true),
        );
        if (resp.statusCode != null && resp.statusCode! >= 200 && resp.statusCode! < 300) success++; else { failed++; errors.add('${c.callsign}: HTTP ${resp.statusCode}'); }
      } catch (e) { failed++; errors.add('${c.callsign}: $e'); }
    }
    return SyncResult(success: success, failed: failed, errors: errors);
  }

  Future<List<StationInfo>> fetchStationInfo(String baseUrl, String apiKey) async {
    try {
      final url = baseUrl.trimRight().replaceAll(RegExp(r'/+$'), '') + '/index.php/api/station_info/$apiKey';
      final resp = await _dio.get(url, options: Options(headers: {'Accept': 'application/json'})); final arr = resp.data as List;
      return arr.map((o) => StationInfo(o['station_id']?.toString()??'', o['station_profile_name']?.toString()??'')).toList();
    } catch (_) { return []; }
  }

  Future<bool> testConnection(String baseUrl, String apiKey) async {
    try {
      final url = baseUrl.trimRight().replaceAll(RegExp(r'/+$'), '') + '/index.php/api/qso';
      final body = jsonEncode({'key': apiKey, 'type': 'adif', 'string': '<CALL:6>TEST01 <BAND:3>20m <MODE:3>SSB <QSO_DATE:8>20260101 <TIME_ON:6>000000 <RST_SENT:3>599 <RST_RCVD:3>599 <EOR>'});
      final resp = await _dio.post(url, data: body, options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, validateStatus: (s) => true, sendTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));
      // Cloudlog 返回 4xx 也说明连接成功（只是测试QSO被拒绝）
      final code = resp.statusCode;
      if (code != null && code >= 200 && code < 500) return true;
      // 如果没有 statusCode，看是否有响应数据
      return resp.data != null;
    } catch (_) { return false; }
  }
}

