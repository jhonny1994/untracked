import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:untracked/app/app_exports.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Processing screen with timeout indicator and cancel button.
class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _cancel() {
    unawaited(HapticService.lightImpact());
    ref.read(urlCleanerProvider.notifier).reset();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    // Listen to state changes and navigate when processing completes
    ref.listen<ProcessingState>(urlCleanerProvider, (previous, next) {
      next.when(
        initial: () => context.go(AppRoutes.home),
        loading: (_) {},
        success: (_) => context.go(AppRoutes.result),
        error: (_, _) => context.go(AppRoutes.result),
      );
    });

    final state = ref.watch(urlCleanerProvider);
    final url = state.maybeWhen(
      loading: (url) => url,
      orElse: () => '',
    );

    final isDelayed =
        _elapsedSeconds >= AppConstants.processingTimeoutIndicatorSeconds;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.paddingScreen,
              ),
              child: Semantics(
                label: l10n.accessibilityProcessing,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppDesign.iconContainerSmall,
                      height: AppDesign.iconContainerSmall,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Gap(AppDesign.spaceXLarge),
                    Text(
                      isDelayed
                          ? l10n.processingScreenTimeout
                          : l10n.processingScreenTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDelayed
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(AppDesign.spaceMedium),
                    if (url.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesign.paddingMedium,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            AppDesign.radiusMedium,
                          ),
                        ),
                        child: Text(
                          url.length > AppConstants.maxUrlDisplayLength
                              ? '${url.substring(0, AppConstants.maxUrlDisplayLength)}...'
                              : url,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const Gap(AppDesign.spaceXLarge),
                    // Cancel button
                    TextButton(
                      onPressed: _cancel,
                      child: Text(l10n.processingScreenCancel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
