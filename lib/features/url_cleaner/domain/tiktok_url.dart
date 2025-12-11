import 'package:freezed_annotation/freezed_annotation.dart';

part 'tiktok_url.freezed.dart';

@freezed
abstract class TikTokUrl with _$TikTokUrl {
  const factory TikTokUrl({
    required String originalUrl,
    String? resolvedUrl,
    String? username,
    String? videoId,
    @Default(false) bool isValid,
  }) = _TikTokUrl;
  const TikTokUrl._();

  bool get hasVideoId => videoId != null && videoId!.isNotEmpty;
  bool get hasUsername => username != null && username!.isNotEmpty;
}
