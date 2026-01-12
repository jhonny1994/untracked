import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_intent_notifier.g.dart';

@riverpod
class ShareIntentNotifier extends _$ShareIntentNotifier {
  @override
  String? build() {
    // Listen for shared intents while app is running
    final subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        if (value.isNotEmpty) {
          // Use path for shared text/URLs
          final sharedText = value.first.path;
          // Validate that it's a valid URL before processing
          if (sharedText.isNotEmpty &&
              (Uri.tryParse(sharedText)?.hasScheme ?? false)) {
            state = sharedText;
          }
        }
      },
    );

    // Clean up subscription when provider is disposed
    ref.onDispose(subscription.cancel);

    // Check for initial shared intent (app was opened from share)
    unawaited(_checkInitialIntent());

    return null;
  }

  Future<void> _checkInitialIntent() async {
    try {
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      final path = initial.isNotEmpty ? initial.first.path : '';
      // Validate URL has a scheme before processing
      if (path.isNotEmpty && (Uri.tryParse(path)?.hasScheme ?? false)) {
        state = path;
      }
    } on Exception {
      // Silently ignore share intent errors - not critical
    }
  }

  /// Clear the shared URL after processing and reset the OS-level cache
  void clear() {
    state = null;
    // Reset the initial media cache to prevent re-processing on "Try Again"
    unawaited(ReceiveSharingIntent.instance.reset());
  }
}
