import 'package:untracked/core/core.dart';

/// Service for following TikTok URL redirects
class RedirectService {
  const RedirectService();

  Future<RedirectResult> resolveUrl(String url) async {
    return AppHttpClient.followRedirects(url);
  }
}
