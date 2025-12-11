import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:untracked/features/features.dart';

part 'router.g.dart';

abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const processing = '/processing';
  static const result = '/result';
}

@riverpod
GoRouter router(Ref ref) {
  final hasSeenOnboarding = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: hasSeenOnboarding ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const InputScreen(),
      ),
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
