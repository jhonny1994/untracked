import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Abstract interface for URL parsing.
///
/// Allows mocking in tests and swapping implementations.
abstract interface class IUrlParser {
  /// Checks if [url] is a valid TikTok URL.
  bool isTikTokUrl(String url);

  /// Parses a TikTok URL and extracts username and video ID.
  TikTokUrl parse(String originalUrl, {String? resolvedUrl});

  /// Builds a clean TikTok URL from parsed data.
  String buildCleanUrl(TikTokUrl url);

  /// Extracts a TikTok URL from text that may contain other content.
  String? extractUrl(String text);
}
