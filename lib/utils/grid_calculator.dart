import 'dart:math';

class GridCalculator {
  static String latLngToGrid(double lat, double lng) {
    final adjLat = lat + 90.0;
    final adjLng = lng + 180.0;
    final fieldLon = (adjLng / 20.0).floor().clamp(0, 17);
    final fieldLat = (adjLat / 10.0).floor().clamp(0, 17);
    final field = '${String.fromCharCode(65 + fieldLon)}${String.fromCharCode(65 + fieldLat)}';
    final squareLon = ((adjLng / 2.0) % 10.0).floor().clamp(0, 9);
    final squareLat = ((adjLat / 1.0) % 10.0).floor().clamp(0, 9);
    final square = '$squareLon$squareLat';
    final subLon = (((adjLng * 12.0) % 2.0) * 12.0).floor().clamp(0, 23);
    final subLat = (((adjLat * 24.0) % 1.0) * 24.0).floor().clamp(0, 23);
    final sub = '${String.fromCharCode(97 + subLon)}${String.fromCharCode(97 + subLat)}';
    return '$field$square$sub';
  }
}
