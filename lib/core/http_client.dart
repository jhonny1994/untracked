import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' as http;

import 'package:untracked/core/core.dart';

/// HTTP client for making network requests with proper error handling.
///
/// Provides static methods for GET requests and following redirects.
abstract class AppHttpClient {
  /// Makes a GET request to [url] with configured headers and timeout.
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

  /// Follows HTTP redirects for [url] and returns the final destination.
  ///
  /// [maxHops] limits the number of redirects to follow (default: 5).
  ///
  /// Returns a [RedirectResult] containing:
  /// - The final URL after all redirects
  /// - The number of redirects followed
  /// - Any error that occurred
  ///
  /// Handles special cases:
  /// - 429 (Too Many Requests) → [RedirectError.rateLimited]
  /// - 403 (Forbidden) → [RedirectError.cloudflareBlocked]
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

        AppConstants.httpHeaders.forEach((key, value) {
          request.headers.set(key, value);
        });

        request.followRedirects = false;

        final response = await request.close().timeout(
          AppConstants.httpTimeout,
        );

        // Check for rate limiting
        if (response.statusCode == 429) {
          return RedirectResult(
            finalUrl: currentUrl,
            hops: hops,
            hopCount: hopCount,
            error: RedirectError.rateLimited,
          );
        }

        // Check for Cloudflare/access blocked
        if (response.statusCode == 403) {
          return RedirectResult(
            finalUrl: currentUrl,
            hops: hops,
            hopCount: hopCount,
            error: RedirectError.cloudflareBlocked,
          );
        }

        if (response.isRedirect) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          if (location == null) break;

          currentUrl = Uri.parse(currentUrl).resolve(location).toString();
          hops.add(currentUrl);
          hopCount++;
        } else {
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

/// Result of following HTTP redirects.
@immutable
class RedirectResult {
  /// Creates a new [RedirectResult].
  const RedirectResult({
    required this.finalUrl,
    required this.hops,
    required this.hopCount,
    this.error,
    this.errorMessage,
  });

  /// The final URL after following all redirects.
  final String finalUrl;

  /// List of all URLs visited during redirect chain.
  final List<String> hops;

  /// Number of redirects followed.
  final int hopCount;

  /// Error that occurred, if any.
  final RedirectError? error;

  /// Detailed error message for debugging.
  final String? errorMessage;

  /// Whether an error occurred.
  bool get hasError => error != null;

  /// Whether the redirect was successful.
  bool get isSuccess => error == null;
}

/// Types of errors that can occur during redirect following.
enum RedirectError {
  /// Request timed out.
  timeout,

  /// Network connection failed.
  network,

  /// Server is rate limiting requests (HTTP 429).
  rateLimited,

  /// Cloudflare or server is blocking requests (HTTP 403).
  cloudflareBlocked,

  /// Unknown error occurred.
  unknown,
}
