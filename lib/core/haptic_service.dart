import 'package:flutter/services.dart';

/// Service for haptic feedback across the app.
///
/// Provides semantic methods for different feedback types to ensure
/// consistent user experience.
abstract class HapticService {
  /// Triggers a light impact haptic feedback.
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Triggers a medium impact haptic feedback.
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Triggers a heavy impact haptic feedback.
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Triggers a selection click haptic feedback.
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Triggers haptic feedback for successful operations.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// Triggers haptic feedback for error states.
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Triggers haptic feedback for copy operations.
  static Future<void> copy() async {
    await HapticFeedback.lightImpact();
  }
}
