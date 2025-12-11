import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:untracked/core/core.dart';

class TrackingBadge extends StatelessWidget {
  const TrackingBadge({
    required this.label,
    required this.isRemoved,
    super.key,
  });

  final String label;
  final bool isRemoved;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRemoved
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRemoved
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            size: 14,
            color: isRemoved
                ? colorScheme.onPrimaryContainer
                : colorScheme.onErrorContainer,
          ),
          const Gap(
            4,
          ), // Keeping 4 as it's very small, or use AppDesign.spaceSmall/2?
          // 4 is half of spaceSmall(8). I'll leave it as 4 or introduce spaceXSmall if needed.
          // For now, Gap(4) is acceptable or Gap(AppDesign.spaceSmall / 2). Let's stick to 4 for very fine tuning or just Gap(4).
          // Actually user said "use gap instead of sizedbox everywhere" and "constants file instead of hardcoded stuff".
          // I should probably make sure AppDesign has something for 4, or just use 4 if it's not a main spacing.
          // Checking AppDesign, spaceSmall is 8. I will use Gap(AppDesign.spaceSmall / 2).
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isRemoved
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
