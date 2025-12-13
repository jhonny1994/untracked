import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/link_history/link_history.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'url_cleaner_notifier.g.dart';

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

  Future<void> processUrl(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return;

    // Check for connectivity if it's a short URL (needs redirect)
    // Short URLs: vm.tiktok.com or similar
    final isShortUrl = TikTokPatterns.shortUrlPattern.hasMatch(trimmedUrl);

    if (isShortUrl) {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        await HapticService.error();
        state = const ProcessingState.error(
          error: ProcessingError.offlineShortLink,
        );
        return;
      }
    }

    // Set loading state
    state = ProcessingState.loading(url: trimmedUrl);

    // Clean the URL with timeout protection
    try {
      final (:result, :error) = await _cleanerService
          .cleanUrl(trimmedUrl)
          .timeout(AppConstants.processingTimeout);

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

      // Save to history if enabled
      final settings = ref.read(settingsProvider);
      if (settings.historyEnabled) {
        unawaited(ref.read(historyProvider.notifier).addEntry(result));
      }
    } on TimeoutException {
      await HapticService.error();
      state = const ProcessingState.error(error: ProcessingError.timeout);
    }
  }

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

  Future<void> shareCleanUrl() async {
    final result = state.whenOrNull(success: (r) => r);
    if (result == null) return;

    // Note: Actual sharing is handled in the UI with share_plus
    await HapticService.lightImpact();
  }

  void reset() {
    state = const ProcessingState.initial();
  }
}
