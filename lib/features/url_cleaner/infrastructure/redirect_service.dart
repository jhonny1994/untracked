import 'package:untracked/core/core.dart';

/// Service for following TikTok URL redirects.
///
/// Short TikTok URLs (vm.tiktok.com, vt.tiktok.com) redirect to
/// the full canonical URL. This service follows those redirects.
class RedirectService {
  /// Creates a new [RedirectService] instance.
  const RedirectService();

  /// Follows redirects for [url] and returns the final destination.
  ///
  /// Returns a [RedirectResult] containing the final URL and hop count.
  Future<RedirectResult> resolveUrl(String url) async {
    return AppHttpClient.followRedirects(url);
  }
}
