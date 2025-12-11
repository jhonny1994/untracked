import 'dart:async';
import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' as http;

import 'package:untracked/core/core.dart';

/// HTTP client for making network requests with proper error handling.
///
/// Uses a singleton [HttpClient] for connection reuse and implements
/// exponential backoff for rate-limited requests.
abstract class AppHttpClient {
  static HttpClient? _client;

  /// Gets the singleton [HttpClient] instance with connection keep-alive.
  static HttpClient get _httpClient {
    return _client ??= HttpClient()
      ..connectionTimeout = AppConstants.httpTimeout
      ..idleTimeout = const Duration(seconds: 30)
      ..userAgent = AppConstants.userAgent;
  }

  /// Disposes the HTTP client. Call when app is shutting down.
  static void dispose() {
    _client?.close();
    _client = null;
  }

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
  /// - 429 (Too Many Requests) → Retries with exponential backoff
  /// - 403 (Forbidden) → [RedirectError.cloudflareBlocked]
  static Future<RedirectResult> followRedirects(
    String url, {
    int maxHops = 5,
  }) async {
    return _followRedirectsWithRetry(url, maxHops: maxHops);
  }

  /// Internal method that implements retry with exponential backoff.
  static Future<RedirectResult> _followRedirectsWithRetry(
    String url, {
    required int maxHops,
    int attempt = 0,
  }) async {
    final hops = <String>[url];
    var currentUrl = url;
    var hopCount = 0;

    try {
      while (hopCount < maxHops) {
        final request = await _httpClient.getUrl(Uri.parse(currentUrl));

        AppConstants.httpHeaders.forEach((key, value) {
          request.headers.set(key, value);
        });

        request.followRedirects = false;

        final response = await request.close().timeout(
          AppConstants.httpTimeout,
        );

        // Handle rate limiting with exponential backoff
        if (response.statusCode == 429) {
          // Drain the response body to free up the connection
          await response.drain<void>();

          if (attempt < AppConstants.maxRetries) {
            final backoffMs = _calculateBackoff(attempt);
            await Future<void>.delayed(Duration(milliseconds: backoffMs));
            return _followRedirectsWithRetry(
              url,
              maxHops: maxHops,
              attempt: attempt + 1,
            );
          }
          return RedirectResult(
            finalUrl: currentUrl,
            hops: hops,
            hopCount: hopCount,
            error: RedirectError.rateLimited,
          );
        }

        // Check for Cloudflare/access blocked
        if (response.statusCode == 403) {
          await response.drain<void>();
          return RedirectResult(
            finalUrl: currentUrl,
            hops: hops,
            hopCount: hopCount,
            error: RedirectError.cloudflareBlocked,
          );
        }

        if (response.isRedirect) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          await response.drain<void>();
          if (location == null) break;

          currentUrl = Uri.parse(currentUrl).resolve(location).toString();
          hops.add(currentUrl);
          hopCount++;
        } else {
          await response.drain<void>();
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
    }
  }

  /// Calculates exponential backoff delay in milliseconds.
  static int _calculateBackoff(int attempt) {
    final baseMs = AppConstants.initialBackoff.inMilliseconds;
    final maxMs = AppConstants.maxBackoff.inMilliseconds;
    // 2^attempt * baseMs, capped at maxMs
    final backoffMs = baseMs * (1 << attempt);
    return min(backoffMs, maxMs);
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
