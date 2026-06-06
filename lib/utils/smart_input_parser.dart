class ParsedFields {
  final String callsign;
  final String frequencyMHz;
  final String mode;
  final String rstSent;
  final String rstReceived;
  final String powerTx;
  final String powerRx;
  final String notes;

  const ParsedFields({
    this.callsign = '',
    this.frequencyMHz = '',
    this.mode = '',
    this.rstSent = '',
    this.rstReceived = '',
    this.powerTx = '',
    this.powerRx = '',
    this.notes = '',
  });
}

class SmartInputParser {
  static final _callsignRegex = RegExp(r'^[A-Za-z]{1,2}[0-9][A-Za-z]{1,4}');
  static final _frequencyRegex = RegExp(r'^\d{1,7}$');
  static final _frequencyWithDotRegex = RegExp(r'^\d{1,3}\.\d{1,6}$');
  static final _rstRegex = RegExp(r'^[1-5][1-9]$');
  static final _powerRegex = RegExp(r'^(\d+)\s*(W|KW|w|kw|mW|mw)');

  static const _modeKeywords = {
    'SSB', 'USB', 'LSB', 'CW', 'FM', 'AM', 'RTTY', 'FT8', 'FT4',
    'PSK31', 'PSK63', 'JT65', 'JT9', 'MSK144', 'FSK441', 'ISCAT',
    'Q65', 'FST4', 'FST4W', 'FREEDV', 'SSTV', 'MFSK', 'OLIVIA', 'CONTESTIA',
    'JS8', 'VARAC', 'VARA', 'ARDOP', 'PKT', 'TOR'
  };

  static ParsedFields parse(String input) {
    String callsign = '';
    String frequencyMHz = '';
    String mode = '';
    String rstSent = '';
    String rstReceived = '';
    String powerTx = '';
    String powerRx = '';
    final notesParts = <String>[];
    int rstCount = 0;
    int powerCount = 0;
    final tokens = input.trim().split(RegExp(r'\s+'));
    final processed = <int>{};

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.isEmpty) continue;
      if (frequencyMHz.isEmpty && _frequencyRegex.hasMatch(token)) {
        frequencyMHz = _formatFrequency(token);
        processed.add(i);
        continue;
      }
      if (frequencyMHz.isEmpty && _frequencyWithDotRegex.hasMatch(token)) {
        frequencyMHz = token;
        processed.add(i);
        continue;
      }
      if (mode.isEmpty && _modeKeywords.contains(token.toUpperCase())) {
        mode = token.toUpperCase();
        processed.add(i);
        continue;
      }
      if (_rstRegex.hasMatch(token) && rstCount < 2) {
        if (rstCount == 0) rstSent = token; else rstReceived = token;
        rstCount++;
        processed.add(i);
        continue;
      }
      final pm = _powerRegex.firstMatch(token.toUpperCase());
      if (pm != null && powerCount < 2) {
        if (powerCount == 0) powerTx = token.toUpperCase(); else powerRx = token.toUpperCase();
        powerCount++;
        processed.add(i);
        continue;
      }
    }
    for (int i = 0; i < tokens.length; i++) {
      if (processed.contains(i)) continue;
      final token = tokens[i];
      if (token.isEmpty) continue;
      if (callsign.isEmpty && _callsignRegex.hasMatch(token.toUpperCase())) {
        callsign = token.toUpperCase();
        processed.add(i);
        continue;
      }
    }
    for (int i = 0; i < tokens.length; i++) {
      if (processed.contains(i)) continue;
      final token = tokens[i];
      if (token.isEmpty) continue;
      if (token.toUpperCase() == callsign || token == frequencyMHz) continue;
      if (token.runes.every((r) => (r >= 65 && r <= 90) || (r >= 97 && r <= 122))) continue;
      if (RegExp(r'^[A-Za-z].*[0-9]').hasMatch(token)) continue;
      notesParts.add(token);
    }
    return ParsedFields(
      callsign: callsign, frequencyMHz: frequencyMHz, mode: mode,
      rstSent: rstSent, rstReceived: rstReceived,
      powerTx: powerTx, powerRx: powerRx,
      notes: notesParts.join(' '),
    );
  }

  static String _formatFrequency(String digits) {
    final num = int.tryParse(digits);
    if (num == null) return digits;
    if (num < 1000) return digits;
    final s = digits;
    final dotPos = s.length - 3;
    return '${s.substring(0, dotPos)}.${s.substring(dotPos)}';
  }
}
