import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'processing_state.freezed.dart';

/// State of URL processing
@freezed
sealed class ProcessingState with _$ProcessingState {
  /// Initial state - waiting for input
  const factory ProcessingState.initial() = ProcessingStateInitial;

  /// Processing the URL
  const factory ProcessingState.loading({
    required String url,
  }) = ProcessingStateLoading;

  /// Successfully cleaned the URL
  const factory ProcessingState.success({
    required CleanResult result,
  }) = ProcessingStateSuccess;

  /// Error occurred during processing
  const factory ProcessingState.error({
    required ProcessingError error,
    String? message,
  }) = ProcessingStateError;
}

/// Types of processing errors
enum ProcessingError {
  /// URL is not a valid TikTok URL
  notTikTok,

  /// Network timeout
  timeout,

  /// Network error (no connection)
  network,

  /// Could not extract video ID or username
  extractionFailed,

  /// Rate limited by TikTok
  rateLimited,

  /// Blocked by Cloudflare
  cloudflareBlocked,

  /// Clipboard operation failed
  clipboardFailed,

  /// Unknown error
  unknown,
}
