import 'package:flutter_test/flutter_test.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

void main() {
  group('UrlCleanerService', () {
    late UrlCleanerService service;
    late UrlParser parser;

    setUp(() {
      parser = const UrlParser();
      service = const UrlCleanerService(
        redirectService: RedirectService(),
        urlParser: UrlParser(),
      );
    });

    group('cleanUrl - canonical URLs (offline mode)', () {
      test('cleans canonical URL without network call', () async {
        const url =
            'https://www.tiktok.com/@user/video/1234567890123456789?_r=1&share_token=abc';
        final (:result, :error) = await service.cleanUrl(url);

        expect(error, isNull);
        expect(result, isNotNull);
        expect(
          result!.cleanUrl,
          'https://www.tiktok.com/@user/video/1234567890123456789',
        );
        expect(result.strippedParams, isTrue);
      });

      test('rejects already clean canonical URL', () async {
        const url = 'https://www.tiktok.com/@user/video/1234567890123456789';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result, isNull);
        expect(error, ProcessingError.alreadyClean);
      });

      test('cleans user profile URL with tracking params', () async {
        const url =
            'https://www.tiktok.com/@user?utm_source=share&utm_campaign=test';
        final (:result, :error) = await service.cleanUrl(url);

        expect(error, isNull);
        expect(result, isNotNull);
        expect(result!.cleanUrl, 'https://www.tiktok.com/@user');
      });

      test('handles mobile domain URLs', () async {
        const url =
            'https://m.tiktok.com/@user/video/1234567890123456789?param=value';
        final (:result, :error) = await service.cleanUrl(url);

        expect(error, isNull);
        expect(result!.cleanUrl, contains('@user'));
        expect(result.cleanUrl.contains('?'), isFalse);
      });
    });

    group('Input validation', () {
      test('rejects non-TikTok URL', () async {
        const url = 'https://youtube.com/watch?v=123';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result, isNull);
        expect(error, ProcessingError.notTikTok);
      });

      test('extracts TikTok URL from mixed text', () async {
        const text =
            'Check this out! https://www.tiktok.com/@user/video/1234567890123456789?_r=1 #fyp';
        final (:result, :error) = await service.cleanUrl(text);

        expect(error, isNull);
        expect(result, isNotNull);
        expect(
          result!.cleanUrl,
          'https://www.tiktok.com/@user/video/1234567890123456789',
        );
      });

      test('handles empty string', () async {
        const url = '';
        final parsed = parser.parse(url);

        expect(parsed.isValid, isFalse);
      });

      test('handles whitespace-only string', () async {
        const url = '   ';
        final parsed = parser.parse(url);

        expect(parsed.isValid, isFalse);
      });
    });

    group('URL building', () {
      test('normalizes URL to www.tiktok.com', () async {
        const url =
            'https://m.tiktok.com/@mobile_user/video/9999999999999999999?ref=app';
        final (:result, :error) = await service.cleanUrl(url);

        expect(error, isNull);
        expect(result!.cleanUrl, startsWith('https://www.tiktok.com/@'));
      });

      test('preserves username and videoId only', () async {
        const url =
            'https://www.tiktok.com/@testuser/video/1111111111111111111?share_app_id=1233&sender_device=pc&_r=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(error, isNull);
        expect(
          result!.cleanUrl,
          'https://www.tiktok.com/@testuser/video/1111111111111111111',
        );
        expect(result.original.username, 'testuser');
        expect(result.original.videoId, '1111111111111111111');
      });
    });

    group('CleanResult data', () {
      test('includes original parsed URL data', () async {
        const url =
            'https://www.tiktok.com/@creator/video/7777777777777777777?param=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(error, isNull);
        expect(result!.original.originalUrl, url);
        expect(result.original.username, 'creator');
        expect(result.original.videoId, '7777777777777777777');
      });

      test('sets stripedParams correctly', () async {
        const url =
            'https://www.tiktok.com/@user/video/1234567890123456789?_r=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result!.strippedParams, isTrue);
      });

      test('handles no redirects for canonical URLs', () async {
        const url =
            'https://www.tiktok.com/@user/video/1234567890123456789?param=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result!.redirectHops, 0);
      });
    });

    group('complex tracking parameters', () {
      test('removes all common tracking parameters', () async {
        const url =
            'https://www.tiktok.com/@user/video/1234567890123456789?'
            '_r=1&'
            'share_app_id=1233&'
            'share_token=abc123&'
            'utm_source=twitter&'
            'utm_campaign=test&'
            'is_from_webapp=1&'
            'sender_device=pc&'
            'sec_uid=MS4wLjABAAAA';
        final (:result, :error) = await service.cleanUrl(url);

        expect(error, isNull);
        expect(
          result!.cleanUrl,
          'https://www.tiktok.com/@user/video/1234567890123456789',
        );
        expect(result.cleanUrl.contains('_r'), isFalse);
        expect(result.cleanUrl.contains('share'), isFalse);
        expect(result.cleanUrl.contains('utm'), isFalse);
        expect(result.cleanUrl.contains('sec_uid'), isFalse);
      });
    });

    group('username variations', () {
      test('handles usernames with dots', () async {
        const url =
            'https://www.tiktok.com/@user.name/video/1234567890123456789?p=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result!.cleanUrl, contains('@user.name'));
      });

      test('handles usernames with underscores', () async {
        const url =
            'https://www.tiktok.com/@user_name/video/1234567890123456789?p=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result!.cleanUrl, contains('@user_name'));
      });

      test('handles usernames with numbers', () async {
        const url =
            'https://www.tiktok.com/@user123/video/1234567890123456789?p=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result!.cleanUrl, contains('@user123'));
      });

      test('handles mixed username characters', () async {
        const url =
            'https://www.tiktok.com/@cool_user.name_123/video/1234567890123456789?p=1';
        final (:result, :error) = await service.cleanUrl(url);

        expect(result!.cleanUrl, contains('@cool_user.name_123'));
      });
    });
  });
}
