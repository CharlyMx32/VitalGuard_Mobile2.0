import 'dart:async';
import 'package:flutter/services.dart';

class SosAlarmAudio {
  SosAlarmAudio._();

  static final MethodChannel _channel = const MethodChannel('vitalguard/sos_alarm');
  static Timer? _vibeTimer;

  static Future<void> start() async {
    try {
      final success = await _channel.invokeMethod<bool>('playAlarm');
      if (success != true) {
        _startVibrationFallback();
      }
    } catch (_) {
      _startVibrationFallback();
    }
  }

  static void _startVibrationFallback() {
    _vibeTimer?.cancel();
    HapticFeedback.heavyImpact();
    _vibeTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      HapticFeedback.heavyImpact();
    });
  }

  static Future<void> stop() async {
    _vibeTimer?.cancel();
    _vibeTimer = null;
    try {
      await _channel.invokeMethod('stopAlarm');
    } catch (_) {}
  }
}
