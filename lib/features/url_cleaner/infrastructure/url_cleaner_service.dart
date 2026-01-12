import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Main service for cleaning TikTok URLs by removing tracking parameters.
///
/// This service handles the complete URL cleaning workflow:
/// 1. Validates that the URL is a TikTok URL
/// 2. Follows redirects for short URLs (vm.tiktok.com, vt.tiktok.com)
/// 3. Extracts username and video ID
/// 4. Builds a clean URL without tracking parameters
class UrlCleanerService implements IUrlCleanerService {
  /// Creates a new [UrlCleanerService] with the required dependencies.
  const UrlCleanerService({
    required this.redirectService,
    required this.urlParser,
  });

  /// Service for following URL redirects.
  final RedirectService redirectService;

  /// Parser for extracting data from TikTok URLs.
  final UrlParser urlParser;

  /// Cleans a TikTok URL by removing all tracking parameters.
  ///
  /// [inputUrl] can be any TikTok URL format (short, full, with tracking).
  ///
  /// Returns a record with either:
  /// - `result`: A [CleanResult] with the cleaned URL on success
  /// - `error`: A [ProcessingError] on failure
  ///
  /// Supports offline mode for canonical URLs that don't require redirects.
  @override
  Future<({CleanResult? result, ProcessingError? error})> cleanUrl(
    String inputUrl,
  ) async {
    final extractedUrl = urlParser.extractUrl(inputUrl) ?? inputUrl;

    if (!urlParser.isTikTokUrl(extractedUrl)) {
      return (result: null, error: ProcessingError.notTikTok);
    }

    // Smart Offline Mode: If it's already a full video URL (canonical),
    // we don't strictly need network.
    final preCheckUrl = urlParser.parse(extractedUrl);
    if (preCheckUrl.hasVideoId || preCheckUrl.hasUsername) {
      // Check if the URL is already clean (no tracking params)
      // If so, reject it since there's nothing to clean
      final isAlreadyClean = !extractedUrl.contains('?');
      if (isAlreadyClean) {
        return (result: null, error: ProcessingError.alreadyClean);
      }

      // It's already canonical or a user profile.
      // We can skip the redirect network call and just clean it directly.
      final cleanUrl = urlParser.buildCleanUrl(preCheckUrl);
      return (
        result: CleanResult(
          original: preCheckUrl,
          cleanUrl: cleanUrl,
          strippedParams: true,
        ),
        error: null,
      );
    }

    // Follow redirects for short links (vm/vt.tiktok.com) or non-canonical links
    final redirectResult = await redirectService.resolveUrl(extractedUrl);

    // Handle redirect errors with Regex Fallback
    if (redirectResult.hasError) {
      // If network failed but we have a partially valid URL that we can
      // validly clean via regex, let's try that as a fallback.
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

  /// Maps redirect errors to processing errors.
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
