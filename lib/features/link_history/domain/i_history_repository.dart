import 'package:untracked/features/link_history/link_history.dart';
import 'package:untracked/features/url_cleaner/url_cleaner.dart';

/// Abstract interface for link history repository.
///
/// Allows mocking in tests and swapping storage implementations.
abstract interface class IHistoryRepository {
  /// Loads all history entries sorted by date (newest first).
  Future<List<LinkHistoryEntry>> loadAll();

  /// Adds a new entry to the history.
  Future<void> addEntry(CleanResult result);

  /// Deletes a specific entry from the history.
  Future<void> deleteEntry(LinkHistoryEntry entry);

  /// Clears all history entries.
  Future<void> clearAll();

  /// Restores a previously deleted entry.
  Future<void> restoreEntry(LinkHistoryEntry entry);
}
