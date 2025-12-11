import 'package:flutter/services.dart';

/// Service for clipboard operations with proper error handling.
abstract class ClipboardService {
  /// Copies [text] to the system clipboard.
  ///
  /// Returns `true` if copy was successful, `false` otherwise.
  static Future<bool> copy(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
  }

  /// Pastes text from the system clipboard.
  ///
  /// Returns the clipboard text if available, `null` otherwise.
  static Future<String?> paste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } on PlatformException catch (_) {
      return null;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Checks if the clipboard contains text.
  ///
  /// Returns `true` if clipboard has non-empty text, `false` otherwise.
  static Future<bool> hasText() async {
    final text = await paste();
    return text != null && text.isNotEmpty;
  }
}
