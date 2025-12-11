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

  /// Clean a TikTok URL by following redirects and stripping tracking params
  Future<({CleanResult? result, ProcessingError? error})> cleanUrl(
    String inputUrl,
  ) async {
    // Validate it's a TikTok URL
    if (!urlParser.isTikTokUrl(inputUrl)) {
      return (result: null, error: ProcessingError.notTikTok);
    }

    // Follow redirects to get the final URL
    final redirectResult = await redirectService.resolveUrl(inputUrl);

    // Handle redirect errors
    if (redirectResult.hasError) {
      return (
        result: null,
        error: _mapRedirectError(redirectResult.error!),
      );
    }

    // Parse the resolved URL
    final parsedUrl = urlParser.parse(
      inputUrl,
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
            inputUrl.contains('?') ||
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
