import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'processing_state.freezed.dart';

/// Represents the current state of URL processing.
///
/// Uses sealed class pattern for exhaustive state handling.
@freezed
@immutable
sealed class ProcessingState with _$ProcessingState {
  /// Initial state before any URL is submitted.
  const factory ProcessingState.initial() = ProcessingStateInitial;

  /// Loading state while URL is being processed.
  const factory ProcessingState.loading({
    required String url,
  }) = ProcessingStateLoading;

  /// Success state with the cleaned result.
  const factory ProcessingState.success({
    required CleanResult result,
  }) = ProcessingStateSuccess;

  /// Error state with the error type and optional message.
  const factory ProcessingState.error({
    required ProcessingError error,
    String? message,
  }) = ProcessingStateError;
}

/// Types of errors that can occur during URL processing.
enum ProcessingError {
  /// URL is not a TikTok link.
  notTikTok,

  /// Network request timed out.
  timeout,

  /// Network connection failed.
  network,

  /// Short link requires internet connection to expand.
  offlineShortLink,

  /// Failed to extract video ID from URL.
  extractionFailed,

  /// TikTok is rate limiting requests.
  rateLimited,

  /// Cloudflare or TikTok is blocking requests.
  cloudflareBlocked,

  /// Failed to copy to clipboard.
  clipboardFailed,

  /// URL is already clean with no tracking parameters.
  alreadyClean,

  /// Unknown error occurred.
  unknown,
}
