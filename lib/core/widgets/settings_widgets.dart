import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:language_code/language_code.dart';

import 'package:untracked/app/app_exports.dart';
import 'package:untracked/core/core.dart';

/// Minimal circular icon button for theme toggle.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

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
class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

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
                const Gap(18),
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

/// Settings row with theme (left) and language (right).
class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ThemeToggleButton(),
        LanguageDropdown(),
      ],
    );
  }
}
