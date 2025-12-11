import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'clean_result.freezed.dart';

/// Result of cleaning a TikTok URL
@freezed
abstract class CleanResult with _$CleanResult {
  const factory CleanResult({
    /// The original parsed URL
    required TikTokUrl original,

    /// The clean URL without tracking params
    required String cleanUrl,

    /// Number of redirect hops followed
    @Default(0) int redirectHops,

    /// Whether query parameters were stripped
    @Default(false) bool strippedParams,
  }) = _CleanResult;

  const CleanResult._();

  /// The original URL string
  String get originalUrl => original.originalUrl;

  /// Whether the URL was modified
  bool get wasModified => originalUrl != cleanUrl;
}
