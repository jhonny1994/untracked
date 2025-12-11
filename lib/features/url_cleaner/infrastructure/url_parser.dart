import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Service for parsing and validating TikTok URLs
class UrlParser {
  const UrlParser();

  bool isTikTokUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;

    return TikTokPatterns.validDomains.any(
      (domain) => uri.host == domain || uri.host.endsWith('.$domain'),
    );
  }

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
