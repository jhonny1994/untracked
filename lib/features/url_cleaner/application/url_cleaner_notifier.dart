import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'url_cleaner_notifier.g.dart';

/// Notifier for managing URL cleaning state
@riverpod
class UrlCleanerNotifier extends _$UrlCleanerNotifier {
  late final UrlCleanerService _cleanerService;

  @override
  ProcessingState build() {
    _cleanerService = const UrlCleanerService(
      redirectService: RedirectService(),
      urlParser: UrlParser(),
    );
    return const ProcessingState.initial();
  }

  /// Process a TikTok URL
  Future<void> processUrl(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return;

    // Set loading state
    state = ProcessingState.loading(url: trimmedUrl);

    // Clean the URL
    final (:result, :error) = await _cleanerService.cleanUrl(trimmedUrl);

    if (error != null) {
      await HapticService.error();
      state = ProcessingState.error(error: error);
      return;
    }

    // Success - copy to clipboard automatically
    final copied = await ClipboardService.copy(result!.cleanUrl);

    if (!copied) {
      await HapticService.error();
      state = const ProcessingState.error(
        error: ProcessingError.clipboardFailed,
      );
      return;
    }

    await HapticService.success();
    state = ProcessingState.success(result: result);
  }

  /// Copy the clean URL to clipboard
  Future<bool> copyToClipboard() async {
    final result = state.whenOrNull(success: (r) => r);
    if (result == null) return false;

    final copied = await ClipboardService.copy(result.cleanUrl);
    if (copied) {
      await HapticService.copy();
    } else {
      await HapticService.error();
    }
    return copied;
  }

  /// Share the clean URL
  Future<void> shareCleanUrl() async {
    final result = state.whenOrNull(success: (r) => r);
    if (result == null) return;

    // Note: Actual sharing is handled in the UI with share_plus
    await HapticService.lightImpact();
  }

  /// Reset to initial state
  void reset() {
    state = const ProcessingState.initial();
  }
}
