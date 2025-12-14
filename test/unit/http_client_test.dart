import 'package:flutter_test/flutter_test.dart';
import 'package:untracked/core/core.dart';

void main() {
  group('AppHttpClient', () {
    group('RedirectResult', () {
      test('hasError returns true when error is present', () {
        const result = RedirectResult(
          finalUrl: 'https://example.com',
          hops: ['https://example.com'],
          hopCount: 0,
          error: RedirectError.timeout,
        );

        expect(result.hasError, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('isSuccess returns true when no error', () {
        const result = RedirectResult(
          finalUrl: 'https://example.com',
          hops: ['https://example.com'],
          hopCount: 0,
        );

        expect(result.hasError, isFalse);
        expect(result.isSuccess, isTrue);
      });

      test('stores error message when provided', () {
        const errorMsg = 'Connection failed';
        const result = RedirectResult(
          finalUrl: 'https://example.com',
          hops: ['https://example.com'],
          hopCount: 0,
          error: RedirectError.network,
          errorMessage: errorMsg,
        );

        expect(result.errorMessage, errorMsg);
      });

      test('tracks redirect hops correctly', () {
        final hops = [
          'https://vm.tiktok.com/ABC',
          'https://redirect1.com',
          'https://redirect2.com',
          'https://final.com',
        ];
        final result = RedirectResult(
          finalUrl: hops.last,
          hops: hops,
          hopCount: hops.length - 1,
        );

        expect(result.hopCount, 3);
        expect(result.hops.length, 4);
        expect(result.hops.first, 'https://vm.tiktok.com/ABC');
        expect(result.hops.last, 'https://final.com');
      });
    });

    group('RedirectError', () {
      test('has all expected error types', () {
        expect(RedirectError.timeout, isA<RedirectError>());
        expect(RedirectError.network, isA<RedirectError>());
        expect(RedirectError.rateLimited, isA<RedirectError>());
        expect(RedirectError.cloudflareBlocked, isA<RedirectError>());
        expect(RedirectError.unknown, isA<RedirectError>());
      });

      test('error types are distinct', () {
        expect(RedirectError.timeout == RedirectError.network, isFalse);
        expect(
          RedirectError.rateLimited == RedirectError.cloudflareBlocked,
          isFalse,
        );
      });
    });

    group('Constants validation', () {
      test('AppConstants has reasonable timeout values', () {
        expect(AppConstants.httpTimeout.inSeconds, greaterThan(0));
        expect(AppConstants.httpTimeout.inSeconds, lessThanOrEqualTo(30));

        expect(AppConstants.processingTimeout.inSeconds, greaterThan(0));
        expect(AppConstants.processingTimeout.inSeconds, lessThanOrEqualTo(30));
      });

      test('AppConstants has valid retry configuration', () {
        expect(AppConstants.maxRetries, greaterThanOrEqualTo(1));
        expect(AppConstants.maxRetries, lessThanOrEqualTo(10));

        expect(AppConstants.initialBackoff.inMilliseconds, greaterThan(0));
        expect(
          AppConstants.maxBackoff.inMilliseconds,
          greaterThanOrEqualTo(
            AppConstants.initialBackoff.inMilliseconds,
          ),
        );
      });

      test('AppConstants has max redirect hops limit', () {
        expect(AppConstants.maxRedirectHops, greaterThan(0));
        expect(AppConstants.maxRedirectHops, lessThanOrEqualTo(10));
      });

      test('AppConstants has proper headers', () {
        expect(AppConstants.httpHeaders, isNotEmpty);
        expect(AppConstants.httpHeaders.containsKey('User-Agent'), isTrue);
        expect(AppConstants.httpHeaders.containsKey('Accept'), isTrue);
      });
    });

    group('Exponential backoff calculation', () {
      test('backoff increases exponentially', () {
        // Test the backoff pattern (would need to expose _calculateBackoff or test via integration)
        // For now, validate the constants support exponential backoff
        final base = AppConstants.initialBackoff.inMilliseconds;
        final max = AppConstants.maxBackoff.inMilliseconds;

        expect(max, greaterThan(base));
        expect(
          max / base,
          greaterThanOrEqualTo(2),
        ); // At least 2x increase possible
      });
    });
  });

  group('TikTokPatterns', () {
    group('validDomains', () {
      test('contains all expected TikTok domains', () {
        expect(TikTokPatterns.validDomains, contains('tiktok.com'));
        expect(TikTokPatterns.validDomains, contains('www.tiktok.com'));
        expect(TikTokPatterns.validDomains, contains('vm.tiktok.com'));
        expect(TikTokPatterns.validDomains, contains('vt.tiktok.com'));
        expect(TikTokPatterns.validDomains, contains('m.tiktok.com'));
      });
    });

    group('shortUrlPattern', () {
      test('matches short TikTok URLs', () {
        expect(
          TikTokPatterns.shortUrlPattern.hasMatch(
            'https://vm.tiktok.com/ABC123',
          ),
          isTrue,
        );
        expect(
          TikTokPatterns.shortUrlPattern.hasMatch(
            'https://vt.tiktok.com/XYZ789',
          ),
          isTrue,
        );
      });

      test('does not match regular TikTok URLs', () {
        expect(
          TikTokPatterns.shortUrlPattern.hasMatch(
            'https://www.tiktok.com/@user/video/123',
          ),
          isFalse,
        );
      });

      test('extracts short code from URL', () {
        final match = TikTokPatterns.shortUrlPattern.firstMatch(
          'https://vm.tiktok.com/ABC123',
        );
        expect(match?.group(1), 'ABC123');
      });
    });

    group('videoUrlPattern', () {
      test('matches full video URLs', () {
        expect(
          TikTokPatterns.videoUrlPattern.hasMatch(
            'https://www.tiktok.com/@user/video/1234567890123456789',
          ),
          isTrue,
        );
      });

      test('extracts username and video ID', () {
        final match = TikTokPatterns.videoUrlPattern.firstMatch(
          'https://www.tiktok.com/@testuser/video/9876543210987654321',
        );
        expect(match?.group(1), 'testuser');
        expect(match?.group(2), '9876543210987654321');
      });
    });

    group('userUrlPattern', () {
      test('matches user profile URLs', () {
        expect(
          TikTokPatterns.userUrlPattern.hasMatch(
            'https://www.tiktok.com/@username',
          ),
          isTrue,
        );
      });

      test('extracts username', () {
        final match = TikTokPatterns.userUrlPattern.firstMatch(
          'https://www.tiktok.com/@cool_user',
        );
        expect(match?.group(1), 'cool_user');
      });
    });

    group('stripQueryParams', () {
      test('removes query parameters', () {
        final result = TikTokPatterns.stripQueryParams(
          'https://www.tiktok.com/@user/video/123?param1=value1&param2=value2',
        );
        expect(result, 'https://www.tiktok.com/@user/video/123');
      });

      test('returns unchanged URL when no query params', () {
        const url = 'https://www.tiktok.com/@user/video/123';
        final result = TikTokPatterns.stripQueryParams(url);
        expect(result, url);
      });
    });

    group('buildCleanUrl', () {
      test('builds correct video URL', () {
        final result = TikTokPatterns.buildCleanUrl(
          'testuser',
          '1234567890123456789',
        );
        expect(
          result,
          'https://www.tiktok.com/@testuser/video/1234567890123456789',
        );
      });
    });

    group('buildUserUrl', () {
      test('builds correct user profile URL', () {
        final result = TikTokPatterns.buildUserUrl('username');
        expect(result, 'https://www.tiktok.com/@username');
      });
    });
  });
}
