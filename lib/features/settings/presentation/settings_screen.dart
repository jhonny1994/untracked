import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:language_code/language_code.dart';
import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/link_history/link_history.dart';

/// Settings screen with theme, language, and history management.
/// Uses CustomScrollView + SliverAppBar to avoid nested Scaffold issues.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final history = ref.watch(historyProvider);
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(l10n.settingsTitle),
          centerTitle: true,
          floating: true,
          snap: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppDesign.paddingScreen),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Theme Section
              Text(
                l10n.settingsTheme,
                style: theme.textTheme.titleMedium,
              ),
              const Gap(AppDesign.spaceSmall),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.settingsThemeSystem),
                    icon: const Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.settingsThemeLight),
                    icon: const Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.settingsThemeDark),
                    icon: const Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) async {
                  await HapticService.lightImpact();
                  await ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(newSelection.first);
                },
              ),
              const Gap(AppDesign.spaceMedium),
              const Divider(),
              const Gap(AppDesign.spaceMedium),

              // Language Section
              Text(
                l10n.settingsLanguage,
                style: theme.textTheme.titleMedium,
              ),
              const Gap(AppDesign.spaceSmall),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  LanguageCodes.fromCode(
                    settings.locale?.languageCode ?? 'en',
                  ).nativeName,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await HapticService.lightImpact();
                  if (!context.mounted) return;
                  await _showLanguageSheet(context, ref, settings);
                },
              ),
              const Gap(AppDesign.spaceSmall),
              const Divider(),
              const Gap(AppDesign.spaceMedium),

              // History Section
              Text(
                l10n.historyTitle,
                style: theme.textTheme.titleMedium,
              ),
              const Gap(AppDesign.spaceSmall),
              SwitchListTile(
                title: Text(l10n.settingsHistoryEnabled),
                subtitle: Text(
                  settings.historyEnabled
                      ? l10n.settingsHistoryEnabledSubtitle
                      : l10n.settingsHistoryDisabledSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: settings.historyEnabled,
                onChanged: (value) async {
                  await HapticService.lightImpact();
                  await ref
                      .read(settingsProvider.notifier)
                      .setHistoryEnabled(enabled: value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(l10n.settingsClearHistory),
                subtitle: Text(l10n.settingsClearHistoryDescription),
                enabled: history.isNotEmpty,
                onTap: history.isEmpty
                    ? null
                    : () => _showClearHistoryConfirmation(context, ref, l10n),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _showClearHistoryConfirmation(
    BuildContext context,
    WidgetRef ref,
    S l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(l10n.settingsClearHistory),
          content: Text(l10n.settingsClearHistoryConfirm),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
              child: Text(l10n.settingsClearHistoryAction),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await HapticService.mediumImpact();
      await ref.read(historyProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.historyClearedSuccess)),
        );
      }
    }
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) async {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final currentCode = settings.locale?.languageCode ?? 'en';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.paddingScreen,
              ),
              child: Text(
                l10n.settingsLanguage,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const Gap(AppDesign.spaceMedium),
            // Language list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: S.delegate.supportedLocales.length,
                itemBuilder: (context, index) {
                  final locale = S.delegate.supportedLocales[index];
                  final langCode = LanguageCodes.fromCode(locale.languageCode);
                  final isSelected = locale.languageCode == currentCode;

                  return ListTile(
                    title: Text(langCode.nativeName),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () async {
                      await HapticService.selectionClick();
                      await ref
                          .read(settingsProvider.notifier)
                          .setLocale(
                            Locale(locale.languageCode),
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
