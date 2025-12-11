import 'package:freezed_annotation/freezed_annotation.dart';

part 'tiktok_url.freezed.dart';

/// Represents a parsed TikTok URL
@freezed
abstract class TikTokUrl with _$TikTokUrl {
  const factory TikTokUrl({
    /// The original URL as received
    required String originalUrl,

    /// The resolved URL after following redirects
    String? resolvedUrl,

    /// Extracted username (without @)
    String? username,

    /// Extracted video ID
    String? videoId,

    /// Whether the URL is valid
    @Default(false) bool isValid,
  }) = _TikTokUrl;

  const TikTokUrl._();

  /// Whether this URL has a video ID
  bool get hasVideoId => videoId != null && videoId!.isNotEmpty;

  /// Whether this URL has a username
  bool get hasUsername => username != null && username!.isNotEmpty;
}
