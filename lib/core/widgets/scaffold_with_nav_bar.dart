import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:untracked/core/core.dart';

/// Scaffold wrapper that displays a floating bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.paddingMedium,
            vertical: AppDesign.paddingSmall,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.paddingSmall,
              vertical: AppDesign.paddingSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.navInput,
                  isSelected: navigationShell.currentIndex == 0,
                  colorScheme: colorScheme,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: l10n.navHistory,
                  isSelected: navigationShell.currentIndex == 1,
                  colorScheme: colorScheme,
                  onTap: () => _onTap(1),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: l10n.navSettings,
                  isSelected: navigationShell.currentIndex == 2,
                  colorScheme: colorScheme,
                  onTap: () => _onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    unawaited(HapticService.selectionClick());
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.paddingSmall,
            vertical: AppDesign.paddingSmall,
          ),
          decoration: isSelected
              ? BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(128),
                  borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: AppDesign.iconMedium),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
