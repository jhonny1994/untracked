import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:language_code/language_code.dart';

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
        initial: () {},
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
                  const Gap(AppDesign.spaceSmall),
                  // Settings row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ThemeToggleButton(),
                      const Gap(AppDesign.spaceSmall),
                      _LanguageDropdown(),
                    ],
                  ),
                  const Spacer(flex: 2),
                  // App icon
                  Container(
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
                  TextField(
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

/// Minimal circular icon button for theme toggle.
class _ThemeToggleButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final themeMode = ref.watch(settingsProvider).themeMode;

    final icon = switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };

    final tooltip = switch (themeMode) {
      ThemeMode.system => l10n.settingsThemeSystem,
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
    };

    return IconButton.filled(
      onPressed: () async {
        await HapticService.selectionClick();
        final nextMode = switch (themeMode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        };
        await ref.read(settingsProvider.notifier).setThemeMode(nextMode);
      },
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Minimal language selector dropdown.
class _LanguageDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final supportedLocales = S.delegate.supportedLocales;
    final currentLocale =
        ref.watch(settingsProvider).locale ?? const Locale('en');

    return PopupMenuButton<Locale>(
      initialValue: currentLocale,
      tooltip: S.of(context).settingsLanguage,
      onSelected: (locale) async {
        await HapticService.selectionClick();
        await ref.read(settingsProvider.notifier).setLocale(locale);
      },
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
      ),
      itemBuilder: (context) => supportedLocales.map((locale) {
        final langCode = LanguageCodes.fromCode(locale.languageCode);
        final isSelected = locale.languageCode == currentLocale.languageCode;

        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: colorScheme.primary,
                )
              else
                const SizedBox(width: 18),
              const Gap(AppDesign.spaceMedium),
              Text(
                langCode.nativeName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 20,
              color: colorScheme.onSurface,
            ),
            const Gap(6),
            Text(
              currentLocale.languageCode.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
