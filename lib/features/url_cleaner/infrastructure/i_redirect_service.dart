import 'package:untracked/core/core.dart';

/// Abstract interface for redirect resolution.
///
/// Allows mocking in tests and swapping implementations.
abstract interface class IRedirectService {
  /// Follows redirects for [url] and returns the final destination.
  Future<RedirectResult> resolveUrl(String url);
}
