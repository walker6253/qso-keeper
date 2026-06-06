import 'package:intl/intl.dart';

/// Simple IANA timezone → offset mapping for common amateur radio locations.
/// Does NOT handle DST transitions – uses standard offset only.
class TimezoneUtil {
  static const Map<String, _TzInfo> _zones = {
    'Asia/Shanghai': _TzInfo('UTC+8 北京/上海', 8.0),
    'Asia/Tokyo': _TzInfo('UTC+9 东京', 9.0),
    'Asia/Seoul': _TzInfo('UTC+9 首尔', 9.0),
    'Asia/Bangkok': _TzInfo('UTC+7 曼谷', 7.0),
    'Asia/Jakarta': _TzInfo('UTC+7 雅加达', 7.0),
    'Asia/Kolkata': _TzInfo('UTC+5:30 印度', 5.5),
    'Asia/Dubai': _TzInfo('UTC+4 迪拜', 4.0),
    'Europe/Moscow': _TzInfo('UTC+3 莫斯科', 3.0),
    'Europe/London': _TzInfo('UTC+0 伦敦', 0.0),
    'Europe/Berlin': _TzInfo('UTC+1 柏林', 1.0),
    'Europe/Paris': _TzInfo('UTC+1 巴黎', 1.0),
    'UTC': _TzInfo('UTC+0', 0.0),
    'America/New_York': _TzInfo('UTC-5 纽约', -5.0),
    'America/Chicago': _TzInfo('UTC-6 芝加哥', -6.0),
    'America/Denver': _TzInfo('UTC-7 丹佛', -7.0),
    'America/Los_Angeles': _TzInfo('UTC-8 洛杉矶', -8.0),
    'Pacific/Honolulu': _TzInfo('UTC-10 夏威夷', -10.0),
    'Pacific/Auckland': _TzInfo('UTC+12 奥克兰', 12.0),
    'Australia/Sydney': _TzInfo('UTC+10 悉尼', 10.0),
  };

  static String get defaultZone => 'Asia/Shanghai';

  static List<String> get zoneIds => _zones.keys.toList();

  static String displayName(String zoneId) => _zones[zoneId]?.display ?? zoneId;

  static double offsetHours(String zoneId) => _zones[zoneId]?.offsetHours ?? 8.0;

  /// Format epoch-millis as HH:mm in the given timezone
  static String formatTime(int epochMillis, String zoneId) {
    final offset = offsetHours(zoneId);
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true)
        .add(Duration(milliseconds: (offset * 3600000).round()));
    return DateFormat('HH:mm').format(dt);
  }

  /// Format epoch-millis as HH:mm:ss in the given timezone
  static String formatTimeSeconds(int epochMillis, String zoneId) {
    final offset = offsetHours(zoneId);
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true)
        .add(Duration(milliseconds: (offset * 3600000).round()));
    return DateFormat('HH:mm:ss').format(dt);
  }

  /// Get a TimeOfDay from epoch-millis in the given timezone
  static DateTime dateTimeFromEpoch(int epochMillis, String zoneId) {
    final offset = offsetHours(zoneId);
    return DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: true)
        .add(Duration(milliseconds: (offset * 3600000).round()));
  }
}

class _TzInfo {
  final String display;
  final double offsetHours;
  const _TzInfo(this.display, this.offsetHours);
}
