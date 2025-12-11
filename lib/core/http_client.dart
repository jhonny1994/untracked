import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:untracked/core/core.dart';

/// HTTP client configured for TikTok requests
abstract class AppHttpClient {
  /// Perform GET request with TikTok-compatible headers
  static Future<http.Response> get(Uri url) async {
    final client = http.Client();
    try {
      final response = await client
          .get(url, headers: AppConstants.httpHeaders)
          .timeout(AppConstants.httpTimeout);
      return response;
    } finally {
      client.close();
    }
  }

  /// Follow redirects manually to extract final URL
  /// Returns the final URL after all redirects
  static Future<RedirectResult> followRedirects(
    String url, {
    int maxHops = 5,
  }) async {
    final hops = <String>[url];
    var currentUrl = url;
    var hopCount = 0;

    final client = HttpClient()
      ..connectionTimeout = AppConstants.httpTimeout
      ..userAgent = AppConstants.userAgent;

    try {
      while (hopCount < maxHops) {
        final request = await client.getUrl(Uri.parse(currentUrl));

        // Add headers
        AppConstants.httpHeaders.forEach((key, value) {
          request.headers.set(key, value);
        });

        // Don't auto-follow redirects
        request.followRedirects = false;

        final response = await request.close().timeout(
          AppConstants.httpTimeout,
        );

        // Check for redirect
        if (response.isRedirect) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          if (location == null) break;

          // Handle relative URLs
          currentUrl = Uri.parse(currentUrl).resolve(location).toString();
          hops.add(currentUrl);
          hopCount++;
        } else {
          // No more redirects
          break;
        }
      }

      return RedirectResult(
        finalUrl: currentUrl,
        hops: hops,
        hopCount: hopCount,
      );
    } on TimeoutException {
      return RedirectResult(
        finalUrl: currentUrl,
        hops: hops,
        hopCount: hopCount,
        error: RedirectError.timeout,
      );
    } on SocketException {
      return RedirectResult(
        finalUrl: currentUrl,
        hops: hops,
        hopCount: hopCount,
        error: RedirectError.network,
      );
    } on Object catch (e) {
      return RedirectResult(
        finalUrl: currentUrl,
        hops: hops,
        hopCount: hopCount,
        error: RedirectError.unknown,
        errorMessage: e.toString(),
      );
    } finally {
      client.close();
    }
  }
}

/// Result of following redirects
class RedirectResult {
  const RedirectResult({
    required this.finalUrl,
    required this.hops,
    required this.hopCount,
    this.error,
    this.errorMessage,
  });

  final String finalUrl;
  final List<String> hops;
  final int hopCount;
  final RedirectError? error;
  final String? errorMessage;

  bool get hasError => error != null;
  bool get isSuccess => error == null;
}

/// Possible redirect errors
enum RedirectError {
  timeout,
  network,
  rateLimited,
  cloudflareBlocked,
  unknown,
}
