import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:untracked/app/app_exports.dart';

part 'onboarding_notifier.g.dart';

/// Notifier for tracking onboarding state.
@Riverpod(keepAlive: true)
class OnboardingNotifier extends _$OnboardingNotifier {
  static const _key = 'has_seen_onboarding';

  @override
  bool build() {
    unawaited(_loadState());
    return false; // Default: hasn't seen onboarding
  }

  Future<void> _loadState() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final hasSeenOnboarding = prefs.getBool(_key) ?? false;
    state = hasSeenOnboarding;
  }

  Future<void> completeOnboarding() async {
    state = true;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_key, true);
  }
}
