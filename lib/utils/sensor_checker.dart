import 'package:sensors_plus/sensors_plus.dart';

class SensorChecker {
  static Future<bool> isAccelerometerAvailable() async {
    try {
      await accelerometerEvents.first.timeout(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isGyroscopeAvailable() async {
    try {
      await gyroscopeEvents.first.timeout(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isMagnetometerAvailable() async {
    try {
      await magnetometerEvents.first.timeout(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }
}
