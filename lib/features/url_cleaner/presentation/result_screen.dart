import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(urlCleanerProvider);

    return state.when(
      initial: () => const _BackToHome(),
      loading: (_) => const _BackToHome(),
      success: (result) => _SuccessView(result: result),
      error: (error, message) => _ErrorView(error: error, message: message),
    );
  }
}

class _BackToHome extends StatelessWidget {
  const _BackToHome();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRoutes.home);
    });
    return const Scaffold(body: SizedBox.shrink());
  }
}

class _SuccessView extends ConsumerWidget {
  const _SuccessView({required this.result});

  final CleanResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.paddingScreen,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: AppDesign.iconXLarge,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Gap(AppDesign.spaceLarge),
                  Text(
                    l10n.successScreenTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppDesign.spaceXLarge),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDesign.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _UrlSection(
                            label: l10n.successScreenOriginalLabel,
                            url: result.originalUrl,
                            isOriginal: true,
                            colorScheme: colorScheme,
                            theme: theme,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward_rounded,
                                    size: AppDesign.iconSmall,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _UrlSection(
                            label: l10n.successScreenCleanLabel,
                            url: result.cleanUrl,
                            isOriginal: false,
                            colorScheme: colorScheme,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () async {
                      await HapticService.lightImpact();
                      await SharePlus.instance.share(
                        ShareParams(text: result.cleanUrl),
                      );
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: Text(l10n.successScreenShareButton),
                  ),
                  const Gap(12),
                  OutlinedButton(
                    onPressed: () {
                      ref.read(urlCleanerProvider.notifier).reset();
                      context.go(AppRoutes.home);
                    },
                    child: Text(l10n.successScreenTryAnother),
                  ),
                  const Gap(AppDesign.spaceXLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UrlSection extends StatelessWidget {
  const _UrlSection({
    required this.label,
    required this.url,
    required this.isOriginal,
    required this.colorScheme,
    required this.theme,
  });

  final String label;
  final String url;
  final bool isOriginal;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOriginal
                ? colorScheme.errorContainer
                : colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isOriginal
                  ? colorScheme.onErrorContainer
                  : colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(AppDesign.spaceSmall),
        Text(
          url,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
            decoration: isOriginal ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.error, this.message});

  final ProcessingError error;
  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    final errorMessage = message ?? _getErrorMessage(l10n, error);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.paddingScreen,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: AppDesign.iconXLarge,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const Gap(AppDesign.spaceLarge),
                  Text(
                    errorMessage,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppDesign.spaceXLarge),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(urlCleanerProvider.notifier).reset();
                      context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.tryAgainButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(S l10n, ProcessingError error) {
    return switch (error) {
      ProcessingError.notTikTok => l10n.errorNotTikTok,
      ProcessingError.timeout => l10n.errorNetworkTimeout,
      ProcessingError.network => l10n.errorNetworkTimeout,
      ProcessingError.offlineShortLink => l10n.errorOfflineShortLink,
      ProcessingError.extractionFailed => l10n.errorExtractionFailed,
      ProcessingError.clipboardFailed => l10n.errorClipboardFailed,
      ProcessingError.rateLimited => l10n.errorRateLimited,
      ProcessingError.cloudflareBlocked => l10n.errorCloudflareBlocked,
      ProcessingError.unknown => l10n.errorGeneric,
    };
  }
}
