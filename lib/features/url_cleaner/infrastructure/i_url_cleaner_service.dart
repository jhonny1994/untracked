import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Abstract interface for URL cleaning operations.
///
/// Allows mocking in tests and swapping implementations.
abstract interface class IUrlCleanerService {
  /// Cleans a TikTok URL by removing all tracking parameters.
  ///
  /// Returns a record with either:
  /// - `result`: A [CleanResult] with the cleaned URL on success
  /// - `error`: A [ProcessingError] on failure
  Future<({CleanResult? result, ProcessingError? error})> cleanUrl(
    String inputUrl,
  );
}
