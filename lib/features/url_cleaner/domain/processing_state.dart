import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'processing_state.freezed.dart';

@freezed
sealed class ProcessingState with _$ProcessingState {
  const factory ProcessingState.initial() = ProcessingStateInitial;

  const factory ProcessingState.loading({
    required String url,
  }) = ProcessingStateLoading;

  const factory ProcessingState.success({
    required CleanResult result,
  }) = ProcessingStateSuccess;

  const factory ProcessingState.error({
    required ProcessingError error,
    String? message,
  }) = ProcessingStateError;
}

enum ProcessingError {
  notTikTok,
  timeout,
  network,
  offlineShortLink,
  extractionFailed,
  rateLimited,
  cloudflareBlocked,
  clipboardFailed,
  unknown,
}
