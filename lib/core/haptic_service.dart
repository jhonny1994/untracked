import 'package:flutter/services.dart';

/// Service for haptic feedback
abstract class HapticService {
  /// Light impact feedback (for taps)
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback (for confirmations)
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback (for errors)
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click (for selections)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Success feedback
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// Error feedback
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Copy to clipboard feedback
  static Future<void> copy() async {
    await HapticFeedback.lightImpact();
  }
}
