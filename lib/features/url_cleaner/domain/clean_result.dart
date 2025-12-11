import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'clean_result.freezed.dart';

@freezed
abstract class CleanResult with _$CleanResult {
  const factory CleanResult({
    required TikTokUrl original,
    required String cleanUrl,
    @Default(0) int redirectHops,
    @Default(false) bool strippedParams,
  }) = _CleanResult;
  const CleanResult._();

  String get originalUrl => original.originalUrl;
  bool get wasModified => originalUrl != cleanUrl;
}
