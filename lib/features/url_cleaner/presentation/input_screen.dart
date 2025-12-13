import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Input screen for pasting and processing TikTok links.
class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final text = await ClipboardService.paste();
    if (text != null && text.isNotEmpty) {
      _controller.text = text;
      await HapticService.lightImpact();
    }
  }

  Future<void> _process() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    await HapticService.mediumImpact();
    _focusNode.unfocus();
    await ref.read(urlCleanerProvider.notifier).processUrl(url);
  }

  void _onSharedIntent(String? previous, String? next) {
    if (next != null && next.isNotEmpty) {
      _controller.text = next;
      unawaited(_process());
      ref.read(shareIntentProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    // Listen to state changes and navigate accordingly
    ref.listen<ProcessingState>(urlCleanerProvider, (previous, next) {
      next.when(
        initial: () {
          // Clear the input when returning to home (e.g., from Try Another)
          _controller.clear();
        },
        loading: (_) => context.go(AppRoutes.processing),
        success: (_) => context.go(AppRoutes.result),
        error: (_, _) => context.go(AppRoutes.result),
      );
    });

    // Listen for shared intents and auto-process
    // ignore: cascade_invocations
    ref.listen<String?>(shareIntentProvider, _onSharedIntent);

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
                  // App icon
                  Semantics(
                    label: l10n.accessibilityAppIcon,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppDesign.radiusXLarge,
                        ),
                      ),
                      child: Icon(
                        Icons.link_off_rounded,
                        size: AppDesign.iconLarge,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Gap(AppDesign.spaceXLarge),
                  Text(
                    l10n.inputScreenTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppDesign.spaceSmall),
                  Text(
                    l10n.inputScreenPrivacyNote,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // URL input
                  Semantics(
                    label: l10n.accessibilityUrlInput,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.inputScreenHint,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.content_paste_rounded),
                          onPressed: _paste,
                          tooltip: l10n.inputScreenPasteButton,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _process(),
                    ),
                  ),
                  const Gap(AppDesign.spaceMedium),
                  FilledButton.icon(
                    onPressed: _process,
                    icon: const Icon(Icons.cleaning_services_rounded),
                    label: Text(l10n.inputScreenProcessButton),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
