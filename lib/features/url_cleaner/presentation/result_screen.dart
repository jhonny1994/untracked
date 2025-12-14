import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Result screen displaying success or error states.
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
                  const Spacer(flex: 2),
                  // Success icon
                  Semantics(
                    label: l10n.accessibilitySuccess,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 56,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Gap(AppDesign.spaceLarge),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.successScreenTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(AppDesign.spaceMedium),
                  // Clean URL display
                  Semantics(
                    label: l10n.accessibilityCleanUrl,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDesign.paddingMedium),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppDesign.radiusMedium,
                        ),
                      ),
                      child: SelectableText(
                        result.cleanUrl,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Copy button
                  Semantics(
                    button: true,
                    label: l10n.accessibilityCopyButton,
                    hint: l10n.accessibilityCopyButtonHint,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await HapticService.copy();
                        final success = await ClipboardService.copy(
                          result.cleanUrl,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? l10n.successScreenCopied
                                    : l10n.errorClipboardFailed,
                              ),
                              duration: AppConstants.snackBarDuration,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(l10n.successScreenCopyButton),
                    ),
                  ),
                  const Gap(AppDesign.spaceMedium),
                  // Share button
                  Semantics(
                    button: true,
                    label: l10n.accessibilityShareButton,
                    hint: l10n.accessibilityShareButtonHint,
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        await HapticService.lightImpact();
                        await SharePlus.instance.share(
                          ShareParams(text: result.cleanUrl),
                        );
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: Text(l10n.successScreenShareButton),
                    ),
                  ),
                  const Gap(AppDesign.spaceMedium),
                  // Try another button
                  Semantics(
                    button: true,
                    label: l10n.accessibilityTryAnotherButton,
                    hint: l10n.accessibilityTryAnotherHint,
                    child: TextButton(
                      onPressed: () async {
                        await HapticService.lightImpact();
                        ref.read(urlCleanerProvider.notifier).reset();
                        if (context.mounted) context.go(AppRoutes.home);
                      },
                      child: Text(l10n.successScreenTryAnother),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error view with retry option.
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
                  Semantics(
                    label: l10n.accessibilityError,
                    child: Container(
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
                  ),
                  const Gap(AppDesign.spaceLarge),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      errorMessage,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(AppDesign.spaceXLarge),
                  Semantics(
                    button: true,
                    label: l10n.accessibilityRetryButton,
                    hint: l10n.accessibilityRetryHint,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await HapticService.lightImpact();
                        ref.read(urlCleanerProvider.notifier).reset();
                        if (context.mounted) context.go(AppRoutes.home);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.tryAgainButton),
                    ),
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
      ProcessingError.alreadyClean => l10n.errorAlreadyClean,
      ProcessingError.unknown => l10n.errorGeneric,
    };
  }
}
