import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:untracked/core/core.dart';
import 'package:untracked/features/features.dart';

part 'router.g.dart';

abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const history = '/history';
  static const settings = '/settings';
  static const processing = '/processing';
  static const result = '/result';
}

@riverpod
GoRouter router(Ref ref) {
  final hasSeenOnboarding = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: hasSeenOnboarding ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      // Onboarding route (outside nav shell)
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Input/Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const InputScreen(),
              ),
            ],
          ),
          // Tab 1: History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          // Tab 2: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Modal routes (outside nav shell)
      GoRoute(
        path: AppRoutes.processing,
        name: 'processing',
        builder: (context, state) => const ProcessingScreen(),
      ),
      GoRoute(
        path: AppRoutes.result,
        name: 'result',
        builder: (context, state) => const ResultScreen(),
      ),
    ],
  );
}
