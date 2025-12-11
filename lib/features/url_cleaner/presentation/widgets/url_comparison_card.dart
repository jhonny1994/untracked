import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:untracked/core/core.dart';

class UrlComparisonCard extends StatelessWidget {
  const UrlComparisonCard({
    required this.originalUrl,
    required this.cleanUrl,
    required this.originalLabel,
    required this.cleanLabel,
    super.key,
  });

  final String originalUrl;
  final String cleanUrl;
  final String originalLabel;
  final String cleanLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original URL
            _UrlRow(
              label: originalLabel,
              url: originalUrl,
              labelColor: colorScheme.errorContainer,
              labelTextColor: colorScheme.onErrorContainer,
              isStrikethrough: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDesign.paddingMedium,
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: AppDesign.iconSmall,
                      color: colorScheme.primary,
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),
            ),

            // Clean URL
            _UrlRow(
              label: cleanLabel,
              url: cleanUrl,
              labelColor: colorScheme.primaryContainer,
              labelTextColor: colorScheme.onPrimaryContainer,
              isStrikethrough: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _UrlRow extends StatelessWidget {
  const _UrlRow({
    required this.label,
    required this.url,
    required this.labelColor,
    required this.labelTextColor,
    required this.isStrikethrough,
  });

  final String label;
  final String url;
  final Color labelColor;
  final Color labelTextColor;
  final bool isStrikethrough;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: labelColor,
            borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: labelTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(AppDesign.spaceSmall),
        Text(
          url,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
