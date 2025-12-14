import 'package:flutter_test/flutter_test.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

void main() {
  group('UrlParser', () {
    late UrlParser urlParser;

    setUp(() {
      urlParser = const UrlParser();
    });

    group('isTikTokUrl', () {
      test('returns true for valid tiktok.com URL', () {
        expect(urlParser.isTikTokUrl('https://tiktok.com/@user'), isTrue);
        expect(urlParser.isTikTokUrl('https://www.tiktok.com/@user'), isTrue);
        expect(urlParser.isTikTokUrl('https://m.tiktok.com/@user'), isTrue);
      });

      test('returns true for short TikTok URLs', () {
        expect(urlParser.isTikTokUrl('https://vm.tiktok.com/ABC123'), isTrue);
        expect(urlParser.isTikTokUrl('https://vt.tiktok.com/XYZ789'), isTrue);
      });

      test('returns false for non-TikTok URLs', () {
        expect(urlParser.isTikTokUrl('https://youtube.com/watch'), isFalse);
        expect(urlParser.isTikTokUrl('https://instagram.com/user'), isFalse);
        expect(urlParser.isTikTokUrl('https://google.com'), isFalse);
      });

      test('returns false for malformed URLs', () {
        expect(urlParser.isTikTokUrl('not a url'), isFalse);
        expect(urlParser.isTikTokUrl('tiktok.com'), isFalse); // No scheme
        expect(urlParser.isTikTokUrl(''), isFalse);
      });

      test('handles http and https schemes', () {
        expect(urlParser.isTikTokUrl('http://tiktok.com/@user'), isTrue);
        expect(urlParser.isTikTokUrl('https://tiktok.com/@user'), isTrue);
      });
    });

    group('parse', () {
      test('extracts username and videoId from full video URL', () {
        const url =
            'https://www.tiktok.com/@testuser/video/1234567890123456789';
        final result = urlParser.parse(url);

        expect(result.username, 'testuser');
        expect(result.videoId, '1234567890123456789');
        expect(result.isValid, isTrue);
        expect(result.hasVideoId, isTrue);
        expect(result.hasUsername, isTrue);
      });

      test('extracts username from user profile URL', () {
        const url = 'https://www.tiktok.com/@cooluser';
        final result = urlParser.parse(url);

        expect(result.username, 'cooluser');
        expect(result.videoId, isNull);
        expect(result.isValid, isTrue);
        expect(result.hasVideoId, isFalse);
        expect(result.hasUsername, isTrue);
      });

      test('handles short URL without resolved URL', () {
        const url = 'https://vm.tiktok.com/ABC123';
        final result = urlParser.parse(url);

        expect(result.username, isNull);
        expect(result.videoId, isNull);
        expect(result.isValid, isFalse);
        expect(result.originalUrl, url);
      });

      test('parses resolved URL when provided', () {
        const originalUrl = 'https://vm.tiktok.com/ABC123';
        const resolvedUrl =
            'https://www.tiktok.com/@john_doe/video/9876543210987654321';
        final result = urlParser.parse(originalUrl, resolvedUrl: resolvedUrl);

        expect(result.username, 'john_doe');
        expect(result.videoId, '9876543210987654321');
        expect(result.isValid, isTrue);
        expect(result.originalUrl, originalUrl);
        expect(result.resolvedUrl, resolvedUrl);
      });

      test('handles URLs with tracking parameters', () {
        const url =
            'https://www.tiktok.com/@user/video/1234567890123456789?_r=1&share_app_id=1233&share_token=abc';
        final result = urlParser.parse(url);

        expect(result.username, 'user');
        expect(result.videoId, '1234567890123456789');
        expect(result.isValid, isTrue);
      });

      test('handles usernames with dots and underscores', () {
        const url =
            'https://www.tiktok.com/@user.name_123/video/1234567890123456789';
        final result = urlParser.parse(url);

        expect(result.username, 'user.name_123');
        expect(result.videoId, '1234567890123456789');
      });

      test('handles mobile URLs', () {
        const url =
            'https://m.tiktok.com/@mobile_user/video/1111111111111111111';
        final result = urlParser.parse(url);

        expect(result.username, 'mobile_user');
        expect(result.videoId, '1111111111111111111');
        expect(result.isValid, isTrue);
      });

      test('returns invalid for non-TikTok URL', () {
        const url = 'https://youtube.com/watch?v=123';
        final result = urlParser.parse(url);

        expect(result.isValid, isFalse);
        expect(result.username, isNull);
        expect(result.videoId, isNull);
      });
    });

    group('buildCleanUrl', () {
      test('builds clean URL from username and videoId', () {
        const url =
            'https://www.tiktok.com/@user/video/1234567890123456789?_r=1';
        final parsed = urlParser.parse(url);
        final cleanUrl = urlParser.buildCleanUrl(parsed);

        expect(
          cleanUrl,
          'https://www.tiktok.com/@user/video/1234567890123456789',
        );
        expect(cleanUrl.contains('?'), isFalse);
      });

      test('builds user profile URL when only username is available', () {
        const url = 'https://www.tiktok.com/@user';
        final parsed = urlParser.parse(url);
        final cleanUrl = urlParser.buildCleanUrl(parsed);

        expect(cleanUrl, 'https://www.tiktok.com/@user');
      });

      test('strips query parameters from URL', () {
        const url = 'https://www.tiktok.com/@user?param1=value1&param2=value2';
        final parsed = urlParser.parse(url);
        final cleanUrl = urlParser.buildCleanUrl(parsed);

        expect(cleanUrl, 'https://www.tiktok.com/@user');
      });

      test('handles URLs with complex tracking params', () {
        const url =
            'https://www.tiktok.com/@creator123/video/7777777777777777777?is_from_webapp=1&sender_device=pc&_r=1';
        final parsed = urlParser.parse(url);
        final cleanUrl = urlParser.buildCleanUrl(parsed);

        expect(
          cleanUrl,
          'https://www.tiktok.com/@creator123/video/7777777777777777777',
        );
      });
    });

    group('extractUrl', () {
      test('extracts TikTok URL from text with caption', () {
        const text =
            'Check out this awesome video! https://www.tiktok.com/@user/video/1234567890123456789 #fyp';
        final extracted = urlParser.extractUrl(text);

        expect(
          extracted,
          'https://www.tiktok.com/@user/video/1234567890123456789',
        );
      });

      test('extracts short URL from text', () {
        const text = 'Look at this: https://vm.tiktok.com/ABC123/ amazing!';
        final extracted = urlParser.extractUrl(text);

        expect(extracted, 'https://vm.tiktok.com/ABC123/');
      });

      test('extracts first URL when multiple exist', () {
        const text =
            'First: https://www.tiktok.com/@user1/video/111 and https://www.tiktok.com/@user2/video/222';
        final extracted = urlParser.extractUrl(text);

        expect(extracted, contains('@user1'));
      });

      test('returns null when no TikTok URL in text', () {
        const text = 'This is just plain text without any URLs';
        final extracted = urlParser.extractUrl(text);

        expect(extracted, isNull);
      });

      test('extracts URL with mobile domain', () {
        const text = 'Mobile link: https://m.tiktok.com/@user/video/999';
        final extracted = urlParser.extractUrl(text);

        expect(extracted, 'https://m.tiktok.com/@user/video/999');
      });

      test('handles text with newlines and emoji', () {
        const text = '''
        🔥 Check this out! 🔥
        https://www.tiktok.com/@viral_user/video/5555555555555555555
        Like and share! 👍
        ''';
        final extracted = urlParser.extractUrl(text);

        expect(extracted, contains('viral_user'));
      });
    });

    group('edge cases', () {
      test('handles very long usernames', () {
        const url =
            'https://www.tiktok.com/@this_is_a_very_long_username_123/video/1234567890123456789';
        final result = urlParser.parse(url);

        expect(result.username, 'this_is_a_very_long_username_123');
        expect(result.isValid, isTrue);
      });

      test('handles URLs with fragments', () {
        const url =
            'https://www.tiktok.com/@user/video/1234567890123456789#comment';
        final result = urlParser.parse(url);

        expect(result.username, 'user');
        expect(result.videoId, '1234567890123456789');
      });

      test('handles case variations in domain', () {
        expect(urlParser.isTikTokUrl('https://TikTok.com/@user'), isTrue);
        expect(urlParser.isTikTokUrl('https://TIKTOK.COM/@user'), isTrue);
      });

      test('handles trailing slashes', () {
        const url = 'https://www.tiktok.com/@user/video/1234567890123456789/';
        final result = urlParser.parse(url);

        expect(result.username, 'user');
        expect(result.videoId, '1234567890123456789');
      });
    });
  });
}
