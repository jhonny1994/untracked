import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:untracked/application/application.dart';
import 'package:untracked/core/core.dart';
import 'package:untracked/features/onboarding/application/onboarding_notifier.dart';

/// 3-step onboarding screen for first-time users.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    unawaited(HapticService.selectionClick());
    if (_currentPage < 2) {
      unawaited(
        _pageController.nextPage(
          duration: AppConstants.pageAnimationDuration,
          curve: Curves.easeInOut,
        ),
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    unawaited(HapticService.lightImpact());
    _completeOnboarding();
  }

  void _completeOnboarding() {
    unawaited(HapticService.success());
    unawaited(ref.read(onboardingProvider.notifier).completeOnboarding());
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    final pages = [
      _OnboardingPage(
        icon: Icons.link_off_rounded,
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
        colorScheme: colorScheme,
        theme: theme,
      ),
      _OnboardingPage(
        icon: Icons.cleaning_services_rounded,
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
        colorScheme: colorScheme,
        theme: theme,
      ),
      _OnboardingPage(
        icon: Icons.shield_rounded,
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
        colorScheme: colorScheme,
        theme: theme,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  unawaited(HapticService.selectionClick());
                  setState(() => _currentPage = page);
                },
                children: pages,
              ),
            ),
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDesign.paddingMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom buttons: Skip (left) and Next/GetStarted (right)
            Padding(
              padding: const EdgeInsets.all(AppDesign.paddingScreen),
              child: Row(
                children: [
                  // Skip button
                  TextButton(
                    onPressed: _skip,
                    child: Text(l10n.onboardingSkip),
                  ),
                  const Spacer(),
                  // Next/Get Started button
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 56),
                    ),
                    child: Text(
                      _currentPage == 2
                          ? l10n.onboardingGetStarted
                          : l10n.onboardingNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.colorScheme,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String body;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.paddingScreen,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const Gap(AppDesign.spaceXLarge),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(AppDesign.spaceMedium),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
