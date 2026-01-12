import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Service for parsing and validating TikTok URLs.
///
/// Handles various TikTok URL formats including:
/// - Full video URLs: `tiktok.com/@user/video/123`
/// - User profile URLs: `tiktok.com/@user`
/// - Short URLs: `vm.tiktok.com/ABC123`
class UrlParser implements IUrlParser {
  /// Creates a new [UrlParser] instance.
  const UrlParser();

  /// Checks if [url] is a valid TikTok URL.
  ///
  /// Returns `true` if the URL belongs to a TikTok domain.
  @override
  bool isTikTokUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;

    return TikTokPatterns.validDomains.any(
      (domain) => uri.host == domain || uri.host.endsWith('.$domain'),
    );
  }

  /// Parses a TikTok URL and extracts username and video ID.
  ///
  /// [originalUrl] is the URL as provided by the user.
  /// [resolvedUrl] is the final URL after following redirects (optional).
  ///
  /// Returns a [TikTokUrl] with extracted data.
  @override
  TikTokUrl parse(String originalUrl, {String? resolvedUrl}) {
    final urlToParse = resolvedUrl ?? originalUrl;

    // Try video URL pattern first
    final videoMatch = TikTokPatterns.videoUrlPattern.firstMatch(urlToParse);
    if (videoMatch != null) {
      return TikTokUrl(
        originalUrl: originalUrl,
        resolvedUrl: resolvedUrl,
        username: videoMatch.group(1),
        videoId: videoMatch.group(2),
        isValid: true,
      );
    }

    // Try user URL pattern
    final userMatch = TikTokPatterns.userUrlPattern.firstMatch(urlToParse);
    if (userMatch != null) {
      return TikTokUrl(
        originalUrl: originalUrl,
        resolvedUrl: resolvedUrl,
        username: userMatch.group(1),
        isValid: true,
      );
    }

    // Check if it's a short URL that wasn't resolved
    final shortMatch = TikTokPatterns.shortUrlPattern.firstMatch(urlToParse);
    if (shortMatch != null) {
      return TikTokUrl(
        originalUrl: originalUrl,
        resolvedUrl: resolvedUrl,
      );
    }

    // Not a valid TikTok URL
    return TikTokUrl(
      originalUrl: originalUrl,
      resolvedUrl: resolvedUrl,
    );
  }

  /// Builds a clean TikTok URL from parsed data.
  ///
  /// Strips all tracking parameters and normalizes the URL format.
  @override
  String buildCleanUrl(TikTokUrl url) {
    if (url.hasVideoId && url.hasUsername) {
      return TikTokPatterns.buildCleanUrl(url.username!, url.videoId!);
    } else if (url.hasUsername) {
      return TikTokPatterns.buildUserUrl(url.username!);
    }

    // Fallback: strip query params from resolved/original URL
    final baseUrl = url.resolvedUrl ?? url.originalUrl;
    return TikTokPatterns.stripQueryParams(baseUrl);
  }

  /// Extracts a TikTok URL from text that may contain other content.
  ///
  /// Useful for extracting URLs from shared text that includes
  /// additional content like captions or hashtags.
  ///
  /// Returns the extracted URL or `null` if no TikTok URL is found.
  @override
  String? extractUrl(String text) {
    // Regex to match TikTok URLs buried in text
    final urlPattern = RegExp(
      r'https?://(?:www\.|m\.|vm\.|vt\.)?tiktok\.com/[^\s]+',
      caseSensitive: false,
    );
    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }
}
