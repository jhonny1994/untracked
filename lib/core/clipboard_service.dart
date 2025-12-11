import 'package:flutter/services.dart';

/// Service for clipboard operations
abstract class ClipboardService {
  /// Copy text to clipboard
  static Future<bool> copy(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static Future<String?> paste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<bool> hasText() async {
    final text = await paste();
    return text != null && text.isNotEmpty;
  }
}
