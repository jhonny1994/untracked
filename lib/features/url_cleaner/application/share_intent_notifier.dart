import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_intent_notifier.g.dart';

@riverpod
class ShareIntentNotifier extends _$ShareIntentNotifier {
  @override
  String? build() {
    // Listen for shared intents while app is running
    ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty && value.first.path.isNotEmpty) {
        state = value.first.path;
      }
    });

    // Check for initial shared intent (app was opened from share)
    unawaited(_checkInitialIntent());

    return null;
  }

  Future<void> _checkInitialIntent() async {
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial.isNotEmpty && initial.first.path.isNotEmpty) {
      state = initial.first.path;
    }
  }

  /// Clear the shared URL after processing and reset the OS-level cache
  void clear() {
    state = null;
    // Reset the initial media cache to prevent re-processing on "Try Again"
    unawaited(ReceiveSharingIntent.instance.reset());
  }
}
