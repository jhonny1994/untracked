import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'link_history_entry.freezed.dart';
part 'link_history_entry.g.dart';

/// Represents a single entry in the link history.
@freezed
@HiveType(typeId: 0)
abstract class LinkHistoryEntry with _$LinkHistoryEntry {
  const factory LinkHistoryEntry({
    @HiveField(0) required String originalUrl,
    @HiveField(1) required String cleanUrl,
    @HiveField(2) required DateTime cleanedAt,
    @HiveField(3) String? videoId,
  }) = _LinkHistoryEntry;

  factory LinkHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$LinkHistoryEntryFromJson(json);
}
