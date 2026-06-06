class BandUtil {
  static final _bands = [
    _Band('2200m', 0.135, 0.138), _Band('630m', 0.472, 0.479), _Band('160m', 1.8, 2.0),
    _Band('80m', 3.5, 4.0), _Band('60m', 5.25, 5.45), _Band('40m', 7.0, 7.3),
    _Band('30m', 10.1, 10.15), _Band('20m', 14.0, 14.35), _Band('17m', 18.068, 18.168),
    _Band('15m', 21.0, 21.45), _Band('12m', 24.89, 24.99), _Band('10m', 28.0, 29.7),
    _Band('6m', 50.0, 54.0), _Band('4m', 70.0, 70.5), _Band('2m', 144.0, 148.0),
    _Band('1.25m', 222.0, 225.0), _Band('70cm', 430.0, 440.0),
    _Band('33cm', 902.0, 928.0), _Band('23cm', 1240.0, 1300.0), _Band('13cm', 2300.0, 2450.0),
  ];

  static String autoMode(double mhz) {
    if (mhz <= 0) return '';
    if (mhz < 10.0) return 'LSB';
    if (mhz <= 29.7) return 'USB';
    if (mhz <= 54.0) return 'USB';
    return 'FM';
  }

  static String getBand(double mhz) {
    if (mhz <= 0) return '';
    for (final b in _bands) {
      if (mhz >= b.min && mhz <= b.max) return b.name;
    }
    final meters = (300.0 / mhz).toInt();
    return meters < 100 ? '${meters}m' : '';
  }
}

class _Band { final String name; final double min; final double max; const _Band(this.name, this.min, this.max); }
