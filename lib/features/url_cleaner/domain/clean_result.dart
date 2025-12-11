import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'clean_result.freezed.dart';

/// Result of a successful URL cleaning operation.
///
/// Contains the original parsed URL, the cleaned URL,
/// and metadata about the cleaning process.
@freezed
@immutable
abstract class CleanResult with _$CleanResult {
  /// Creates a new [CleanResult] instance.
  const factory CleanResult({
    /// The parsed original TikTok URL.
    required TikTokUrl original,

    /// The cleaned URL without tracking parameters.
    required String cleanUrl,

    /// Number of HTTP redirects followed to resolve the URL.
    @Default(0) int redirectHops,

    /// Whether tracking parameters were stripped.
    @Default(false) bool strippedParams,
  }) = _CleanResult;
  const CleanResult._();

  /// The original URL as provided by the user.
  String get originalUrl => original.originalUrl;

  /// Whether the URL was modified during cleaning.
  bool get wasModified => originalUrl != cleanUrl;
}
