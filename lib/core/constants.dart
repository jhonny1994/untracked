/// App-wide constants for UNTRACED
abstract class AppConstants {
  static const Duration httpTimeout = Duration(seconds: 10);
  static const int maxRedirectHops = 5;

  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static const Map<String, String> httpHeaders = {
    'User-Agent': userAgent,
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
  };

  // Retry configuration for exponential backoff
  static const int maxRetries = 3;
  static const Duration initialBackoff = Duration(milliseconds: 1000);
  static const Duration maxBackoff = Duration(milliseconds: 8000);
}

/// TikTok URL patterns for validation and extraction
abstract class TikTokPatterns {
  /// Valid TikTok domains
  static const List<String> validDomains = [
    'tiktok.com',
    'www.tiktok.com',
    'vm.tiktok.com',
    'vt.tiktok.com',
    'm.tiktok.com',
  ];

  /// Pattern to match TikTok short URLs (vm.tiktok.com/XXXXXXX)
  static final RegExp shortUrlPattern = RegExp(
    r'https?://(?:vm|vt)\.tiktok\.com/([A-Za-z0-9]+)',
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

/// App-wide design constants for UI consistency
abstract class AppDesign {
  // Spacing (Gap)
  static const double spaceSmall = 8;
  static const double spaceMedium = 16;
  static const double spaceLarge = 24;
  static const double spaceXLarge = 32;

  // Padding
  static const double paddingSmall = 8;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
  static const double paddingScreen = 24;

  // Icon Sizes
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 40;
  static const double iconXLarge = 48;

  // Border Radius
  static const double radiusSmall = 6;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
}
