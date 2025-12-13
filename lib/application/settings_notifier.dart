import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untracked/core/core.dart';

part 'settings_notifier.g.dart';

/// Settings state containing theme mode and locale
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.historyEnabled = true,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final bool historyEnabled;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? historyEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      historyEnabled: historyEnabled ?? this.historyEnabled,
    );
  }
}

/// Provider for SharedPreferences instance
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Notifier for managing app settings with persistence
@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _historyEnabledKey = 'history_enabled';

  @override
  SettingsState build() {
    unawaited(_loadSettings());
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);

    // Check if first launch (no theme setting saved)
    final themeValue = prefs.getString(_themeKey);
    final isFirstLaunch = themeValue == null;

    if (isFirstLaunch) {
      // Auto-detect system locale
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supportedLocales = S.delegate.supportedLocales;
      final locale =
          supportedLocales.any(
            (l) => l.languageCode == systemLocale.languageCode,
          )
          ? Locale(systemLocale.languageCode)
          : const Locale('en');

      // Use system theme initially
      // Save auto-detected defaults
      state = SettingsState(
        locale: locale,
      );
      await prefs.setString(_themeKey, 'system');
      await prefs.setString(_localeKey, locale.languageCode);
      await prefs.setBool(_historyEnabledKey, true);
    } else {
      // Load saved settings
      final themeMode = switch (themeValue) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

      final localeValue = prefs.getString(_localeKey);
      final locale = localeValue != null ? Locale(localeValue) : null;

      final historyEnabled = prefs.getBool(_historyEnabledKey) ?? true;

      state = SettingsState(
        themeMode: themeMode,
        locale: locale,
        historyEnabled: historyEnabled,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeKey, value);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (locale != null) {
      await prefs.setString(_localeKey, locale.languageCode);
    } else {
      await prefs.remove(_localeKey);
    }
  }

  Future<void> setHistoryEnabled({required bool enabled}) async {
    state = state.copyWith(historyEnabled: enabled);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_historyEnabledKey, enabled);
  }
}
