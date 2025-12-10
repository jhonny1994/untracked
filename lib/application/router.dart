import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:untracked/features/url_cleaner/presentation/input_screen.dart';
import 'package:untracked/features/url_cleaner/presentation/processing_screen.dart';
import 'package:untracked/features/url_cleaner/presentation/result_screen.dart';

part 'router.g.dart';

/// Route paths
abstract class AppRoutes {
  static const home = '/';
  static const processing = '/processing';
  static const result = '/result';
}

/// GoRouter provider
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
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
