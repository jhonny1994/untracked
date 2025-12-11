import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:untracked/core/core.dart';

abstract class AppHttpClient {
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

enum RedirectError {
  timeout,
  network,
  rateLimited,
  cloudflareBlocked,
  unknown,
}
