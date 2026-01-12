import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'providers.g.dart';

/// Provider for [UrlParser] service.
@riverpod
UrlParser urlParser(Ref ref) => const UrlParser();

/// Provider for [RedirectService] service.
@riverpod
RedirectService redirectService(Ref ref) => const RedirectService();

/// Provider for [UrlCleanerService] with injected dependencies.
@riverpod
UrlCleanerService urlCleanerService(Ref ref) => UrlCleanerService(
  redirectService: ref.watch(redirectServiceProvider),
  urlParser: ref.watch(urlParserProvider),
);
