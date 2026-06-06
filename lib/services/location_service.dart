import 'package:geolocator/geolocator.dart';
import '../utils/grid_calculator.dart';

class LocationService {
  static Future<({double lat, double lng, String grid, String address})?> getCurrent() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req != LocationPermission.whileInUse && req != LocationPermission.always) return null;
      }
      final pos = await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 10));
      final grid = GridCalculator.latLngToGrid(pos.latitude, pos.longitude);
      return (lat: pos.latitude, lng: pos.longitude, grid: grid, address: '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
    } catch (_) { return null; }
  }
}
