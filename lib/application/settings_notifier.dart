import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_notifier.g.dart';

/// Settings state containing theme mode and locale
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  final ThemeMode themeMode;
  final Locale? locale;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
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

  @override
  SettingsState build() {
    unawaited(_loadSettings());
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);

    // Load theme mode
    final themeValue = prefs.getString(_themeKey);
    final themeMode = switch (themeValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    // Load locale
    final localeValue = prefs.getString(_localeKey);
    final locale = localeValue != null ? Locale(localeValue) : null;

    state = SettingsState(themeMode: themeMode, locale: locale);
  }

  /// Set app theme mode
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

  /// Set app locale
  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (locale != null) {
      await prefs.setString(_localeKey, locale.languageCode);
    } else {
      await prefs.remove(_localeKey);
    }
  }
}
