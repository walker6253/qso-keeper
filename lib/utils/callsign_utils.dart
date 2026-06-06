class CallSignUtils {
  static const _districtMap = {
    '1': '北京', '2': '黑龙江/吉林/辽宁', '3': '天津/内蒙古/河北/山西',
    '4': '上海/山东/江苏', '5': '浙江/江西/福建', '6': '安徽/河南/湖北',
    '7': '湖南/广东/广西/海南', '8': '四川/重庆/贵州/云南',
    '9': '陕西/甘肃/宁夏/青海', '0': '新疆/西藏'
  };

  static String? getProvince(String callsign) {
    if (callsign.length < 3) return null;
    if (callsign[0].toUpperCase() != 'B') return null;
    final digit = callsign.length > 2 ? callsign[2] : null;
    if (digit == null) return null;
    return _districtMap[digit];
  }
}
