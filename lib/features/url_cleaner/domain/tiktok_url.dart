import 'package:freezed_annotation/freezed_annotation.dart';

part 'tiktok_url.freezed.dart';

/// Represents a parsed TikTok URL with extracted data.
///
/// Contains the original URL, optional resolved URL (after redirects),
/// and extracted username/video ID.
@freezed
@immutable
abstract class TikTokUrl with _$TikTokUrl {
  /// Creates a new [TikTokUrl] instance.
  const factory TikTokUrl({
    /// The original URL as provided by the user.
    required String originalUrl,

    /// The resolved URL after following redirects (if any).
    String? resolvedUrl,

    /// The TikTok username (without @).
    String? username,

    /// The video ID.
    String? videoId,

    /// Whether the URL was successfully parsed.
    @Default(false) bool isValid,
  }) = _TikTokUrl;
  const TikTokUrl._();

  /// Whether this URL has a video ID.
  bool get hasVideoId => videoId != null && videoId!.isNotEmpty;

  /// Whether this URL has a username.
  bool get hasUsername => username != null && username!.isNotEmpty;
}
