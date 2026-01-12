import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:untracked/core/core.dart';
import 'package:untracked/features/link_history/link_history.dart';

/// History screen displaying cleaned links with swipe-to-delete and undo.
/// Uses CustomScrollView + SliverAppBar to avoid nested Scaffold issues.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final theme = Theme.of(context);
    final l10n = S.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // Production pattern: Use CustomScrollView to avoid nested Scaffold
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(l10n.historyTitle),
          centerTitle: true,
          floating: true,
          snap: true,
        ),
        if (history.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(l10n, theme),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppDesign.paddingScreen),
            sliver: SliverList.separated(
              itemCount: history.length,
              separatorBuilder: (_, index) => const Gap(AppDesign.spaceSmall),
              itemBuilder: (context, index) => _buildHistoryItem(
                context,
                ref,
                history[index],
                l10n,
                theme,
                locale,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(S l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: AppDesign.iconContainerSmall,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
          ),
          const Gap(AppDesign.spaceMedium),
          Text(
            l10n.historyEmpty,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    LinkHistoryEntry entry,
    S l10n,
    ThemeData theme,
    String locale,
  ) {
    final formattedTime = timeago.format(entry.cleanedAt, locale: locale);

    return Semantics(
      label: entry.cleanUrl,
      child: Dismissible(
        key: ValueKey(
          '${entry.cleanUrl}_${entry.cleanedAt.millisecondsSinceEpoch}',
        ),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppDesign.paddingScreen),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          ),
          child: Icon(
            Icons.delete_rounded,
            color: theme.colorScheme.onError,
          ),
        ),
        confirmDismiss: (_) async {
          await HapticService.mediumImpact();
          return true;
        },
        onDismissed: (_) {
          // Delete entry
          unawaited(ref.read(historyProvider.notifier).deleteEntry(entry));

          // Show undo SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.historyItemDeleted),
              action: SnackBarAction(
                label: l10n.undo,
                onPressed: () async {
                  await HapticService.lightImpact();
                  // Re-add the entry
                  await ref.read(historyProvider.notifier).restoreEntry(entry);
                },
              ),
            ),
          );
        },
        child: Card(
          child: ListTile(
            leading: Icon(
              Icons.link_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              entry.cleanUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(
              formattedTime,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: l10n.copyToClipboard,
              onPressed: () async {
                await HapticService.lightImpact();
                final copied = await ClipboardService.copy(entry.cleanUrl);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        copied
                            ? l10n.historyItemCopied
                            : l10n.errorClipboardFailed,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
