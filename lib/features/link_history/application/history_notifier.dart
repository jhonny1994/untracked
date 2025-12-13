import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:untracked/core/core.dart';
import 'package:untracked/features/link_history/link_history.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

part 'history_notifier.g.dart';

/// Provider for Hive box containing history entries
@Riverpod(keepAlive: true)
Future<Box<LinkHistoryEntry>> historyBox(Ref ref) async {
  final box = await Hive.openBox<LinkHistoryEntry>(AppConstants.historyBoxName);
  return box;
}

/// Notifier for managing link history
@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  @override
  List<LinkHistoryEntry> build() {
    unawaited(_loadHistory());
    return [];
  }

  Future<void> _loadHistory() async {
    final box = await ref.read(historyBoxProvider.future);
    final entries = box.values.toList()
      ..sort((a, b) => b.cleanedAt.compareTo(a.cleanedAt));
    state = entries;
  }

  Future<void> addEntry(CleanResult result) async {
    final box = await ref.read(historyBoxProvider.future);

    // Skip duplicates
    if (box.values.any((e) => e.cleanUrl == result.cleanUrl)) return;

    final entry = LinkHistoryEntry(
      originalUrl: result.originalUrl,
      cleanUrl: result.cleanUrl,
      cleanedAt: DateTime.now(),
      videoId: result.original.videoId,
    );

    await box.add(entry);

    // Enforce max limit (delete oldest)
    if (box.length > AppConstants.maxHistoryEntries) {
      final oldest = box.keys.first;
      await box.delete(oldest);
    }

    await _loadHistory();
  }

  Future<void> deleteEntry(LinkHistoryEntry entry) async {
    final box = await ref.read(historyBoxProvider.future);
    // Find key by matching cleanUrl and cleanedAt
    final key = box.keys.cast<int>().firstWhere(
      (k) =>
          box.get(k)?.cleanUrl == entry.cleanUrl &&
          box.get(k)?.cleanedAt == entry.cleanedAt,
      orElse: () => -1,
    );
    if (key != -1) {
      await box.delete(key);
    }
    await _loadHistory();
  }

  Future<void> clearAll() async {
    final box = await ref.read(historyBoxProvider.future);
    await box.clear();
    state = [];
  }

  /// Restore a previously deleted entry (for undo functionality)
  Future<void> restoreEntry(LinkHistoryEntry entry) async {
    final box = await ref.read(historyBoxProvider.future);
    await box.add(entry);
    await _loadHistory();
  }
}
