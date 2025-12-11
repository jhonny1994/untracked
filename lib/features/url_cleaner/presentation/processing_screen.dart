import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

class ProcessingScreen extends ConsumerWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Gap(AppDesign.spaceXLarge),
                  Text(
                    l10n.processingScreenTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppDesign.spaceMedium),
                  if (url.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDesign.paddingMedium,
                        vertical:
                            12, // Keeping vertical padding custom as it looks specific
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppDesign.radiusMedium,
                        ),
                      ),
                      child: Text(
                        url.length > 40 ? '${url.substring(0, 40)}...' : url,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
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
}
