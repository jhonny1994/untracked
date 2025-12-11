import 'package:flutter/services.dart';

/// Service for haptic feedback
abstract class HapticService {
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> copy() async {
    await HapticFeedback.lightImpact();
  }
}
