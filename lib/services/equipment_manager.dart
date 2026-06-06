import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EquipmentCategory { final String brand; final List<String> models; const EquipmentCategory(this.brand, this.models); }

class EquipmentManager {
  static const _defaultAntennas = ['GP天线', '八木', '倒V', '正V', '长线', 'DP', '端馈', '天调', '磁环'];
  static final _defaultRigs = [
    EquipmentCategory('ICOM', ['IC-7300', 'IC-705', 'IC-9700', 'IC-7610', 'IC-9100']),
    EquipmentCategory('八重洲', ['FT-891', 'FT-710', 'FT-818', 'FT-991', 'FTdx10', 'FT-857', 'FT-817']),
    EquipmentCategory('协谷', ['G90', 'X6100', 'X5105', 'X108G']),
    EquipmentCategory('其他', ['KX3', 'DX-10', 'QRP Labs', 'uSDX']),
  ];

  static Future<List<String>> getAntennas() async {
    final p = await SharedPreferences.getInstance(); final json = p.getString('antennas');
    if (json == null) return List.from(_defaultAntennas);
    try { return (jsonDecode(json) as List).cast<String>(); } catch (_) { return List.from(_defaultAntennas); }
  }

  static Future<void> setAntennas(List<String> list) async {
    (await SharedPreferences.getInstance()).setString('antennas', jsonEncode(list));
  }

  static Future<List<EquipmentCategory>> getRigs() async {
    final p = await SharedPreferences.getInstance(); final json = p.getString('rigs');
    if (json == null) return List.from(_defaultRigs);
    try {
      final arr = jsonDecode(json) as List;
      return arr.map((o) => EquipmentCategory(o['brand'] as String, (o['models'] as List).cast<String>())).toList();
    } catch (_) { return List.from(_defaultRigs); }
  }

  static Future<void> setRigs(List<EquipmentCategory> list) async {
    final arr = list.map((c) => {'brand': c.brand, 'models': c.models}).toList();
    (await SharedPreferences.getInstance()).setString('rigs', jsonEncode(arr));
  }
}
