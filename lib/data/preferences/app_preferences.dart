import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences? _p;
  static Future<void> init() async { _p ??= await SharedPreferences.getInstance(); }
  static String get(String k, [String d=''])=>_p?.getString(k)??d;
  static Future<bool> set(String k, String v)=>_p?.setString(k,v)??Future.value(false);
  static bool getBool(String k, [bool d=false])=>_p?.getBool(k)??d;
  static Future<bool> setBool(String k, bool v)=>_p?.setBool(k,v)??Future.value(false);
  static String get callsign=>get('callsign'); static set callsign(String v)=>set('callsign',v.toUpperCase().trim());
  static String get opName=>get('opName'); static set opName(String v)=>set('opName',v.trim());
  static String get equipment=>get('equipment'); static set equipment(String v)=>set('equipment',v.trim());
  static String get location=>get('location'); static set location(String v)=>set('location',v.trim());
  static String get gridSquare=>get('gridSquare'); static set gridSquare(String v)=>set('gridSquare',v.trim());
  static String get timezone=>get('timezone','Asia/Shanghai'); static set timezone(String v)=>set('timezone',v);
  static String get cloudlogUrl=>get('cloudlogUrl'); static set cloudlogUrl(String v)=>set('cloudlogUrl',v.trim());
  static String get cloudlogApiKey=>get('cloudlogApiKey'); static set cloudlogApiKey(String v)=>set('cloudlogApiKey',v.trim());
  static String get stationProfileId=>get('stationProfileId','1'); static set stationProfileId(String v)=>set('stationProfileId',v);
  static String get stationListJson=>get('stationListJson','[]'); static set stationListJson(String v)=>set('stationListJson',v);
  static bool get autoUploadEnabled=>getBool('autoUploadEnabled'); static set autoUploadEnabled(bool v)=>setBool('autoUploadEnabled',v);
  static String get lastUpdateCheckDate=>get('lastUpdateCheckDate'); static set lastUpdateCheckDate(String v)=>set('lastUpdateCheckDate',v);
  static String get updateIgnoredDate=>get('updateIgnoredDate'); static set updateIgnoredDate(String v)=>set('updateIgnoredDate',v);
}