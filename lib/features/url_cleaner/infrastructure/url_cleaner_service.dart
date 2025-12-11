import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Main service for cleaning TikTok URLs
class UrlCleanerService {
  const UrlCleanerService({
    required this.redirectService,
    required this.urlParser,
  });

  final RedirectService redirectService;
  final UrlParser urlParser;

  Future<({CleanResult? result, ProcessingError? error})> cleanUrl(
    String inputUrl,
  ) async {
    final extractedUrl = urlParser.extractUrl(inputUrl) ?? inputUrl;

    if (!urlParser.isTikTokUrl(extractedUrl)) {
      return (result: null, error: ProcessingError.notTikTok);
    }

    // Smart Offline Mode: If it's already a full video URL (canonical), we don't strictly need network.
    final preCheckUrl = urlParser.parse(extractedUrl);
    if (preCheckUrl.hasVideoId || preCheckUrl.hasUsername) {
      // It's already canonical or a user profile.
      // We can skip the redirect network call and just clean it directly.
      final cleanUrl = urlParser.buildCleanUrl(preCheckUrl);
      return (
        result: CleanResult(
          original: preCheckUrl,
          cleanUrl: cleanUrl,
          strippedParams: extractedUrl.contains('?'),
        ),
        error: null,
      );
    }

    // Follow redirects for short links (vm/vt.tiktok.com) or non-canonical links
    final redirectResult = await redirectService.resolveUrl(extractedUrl);

    // Handle redirect errors with Regex Fallback
    if (redirectResult.hasError) {
      // If network failed but we have a partially valid URL that we can validly clean
      // via regex, let's try that as a fallback instead of erroring out.
      // e.g. if we have a full URL but 403 Forbidden happened.
      if (preCheckUrl.isValid) {
        final cleanUrl = urlParser.buildCleanUrl(preCheckUrl);
        return (
          result: CleanResult(
            original: preCheckUrl,
            cleanUrl: cleanUrl,
            strippedParams: extractedUrl.contains('?'),
          ),
          error: null,
        );
      }

      return (
        result: null,
        error: _mapRedirectError(redirectResult.error!),
      );
    }

    // Parse the resolved URL
    final parsedUrl = urlParser.parse(
      extractedUrl,
      resolvedUrl: redirectResult.finalUrl,
    );

    // Check if we could extract the necessary info
    if (!parsedUrl.isValid) {
      return (result: null, error: ProcessingError.extractionFailed);
    }

    // Build the clean URL
    final cleanUrl = urlParser.buildCleanUrl(parsedUrl);

    return (
      result: CleanResult(
        original: parsedUrl,
        cleanUrl: cleanUrl,
        redirectHops: redirectResult.hopCount,
        strippedParams:
            extractedUrl.contains('?') ||
            (redirectResult.finalUrl.contains('?') && !cleanUrl.contains('?')),
      ),
      error: null,
    );
  }

  /// Map redirect errors to processing errors
  ProcessingError _mapRedirectError(RedirectError error) {
    return switch (error) {
      RedirectError.timeout => ProcessingError.timeout,
      RedirectError.network => ProcessingError.network,
      RedirectError.rateLimited => ProcessingError.rateLimited,
      RedirectError.cloudflareBlocked => ProcessingError.cloudflareBlocked,
      RedirectError.unknown => ProcessingError.unknown,
    };
  }
}
