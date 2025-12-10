/// App-wide constants for UNTRACED
abstract class AppConstants {
  /// HTTP request timeout
  static const Duration httpTimeout = Duration(seconds: 10);

  /// Maximum redirect hops to follow
  static const int maxRedirectHops = 5;

  /// Chrome Mobile User-Agent for HTTP requests
  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  /// HTTP headers for TikTok requests
  static const Map<String, String> httpHeaders = {
    'User-Agent': userAgent,
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
  };
}

/// TikTok URL patterns for validation and extraction
abstract class TikTokPatterns {
  /// Valid TikTok domains
  static const List<String> validDomains = [
    'tiktok.com',
    'www.tiktok.com',
    'vm.tiktok.com',
    'm.tiktok.com',
  ];

  /// Pattern to match TikTok short URLs (vm.tiktok.com/XXXXXXX)
  static final RegExp shortUrlPattern = RegExp(
    r'https?://vm\.tiktok\.com/([A-Za-z0-9]+)',
    caseSensitive: false,
  );

  /// Pattern to match TikTok video URLs with video ID
  static final RegExp videoUrlPattern = RegExp(
    r'https?://(?:www\.|m\.)?tiktok\.com/@([^/]+)/video/(\d+)',
    caseSensitive: false,
  );

  /// Pattern to match TikTok URLs with username only
  static final RegExp userUrlPattern = RegExp(
    r'https?://(?:www\.|m\.)?tiktok\.com/@([^/?]+)',
    caseSensitive: false,
  );

  /// Remove all query parameters from a URL (everything after ?)
  static String stripQueryParams(String url) {
    final questionMarkIndex = url.indexOf('?');
    if (questionMarkIndex == -1) return url;
    return url.substring(0, questionMarkIndex);
  }

  /// Build clean TikTok URL from username and video ID
  static String buildCleanUrl(String username, String videoId) {
    return 'https://www.tiktok.com/@$username/video/$videoId';
  }

  /// Build user profile URL
  static String buildUserUrl(String username) {
    return 'https://www.tiktok.com/@$username';
  }
}
