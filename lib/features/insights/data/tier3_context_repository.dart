import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/memory/data/memory_browser_repository.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';

class Tier3ContextRepository {
  const Tier3ContextRepository(this._browserRepository);

  static const int maxAnchors = 8;
  static const int maxItems = 18;
  static const int maxContentCharacters = 1200;

  final MemoryBrowserRepository _browserRepository;

  Future<Tier3GenerationContext> load() async {
    final items = <String, Tier3ContextItem>{};
    final anchors = await _browserRepository.list(
      MemoryEntityType.capture,
      limit: maxAnchors,
    );

    for (final anchor in anchors) {
      await _addItem(items, anchor);
      if (items.length >= maxItems) break;

      final relationships = await _browserRepository.relationshipsFor(
        entityType: anchor.type.wireName,
        entityId: anchor.id,
      );
      for (final relationship in relationships) {
        if (items.length >= maxItems) break;
        final other = _otherSide(relationship, anchor);
        if (other == null) continue;
        final item = await _browserRepository.getItem(other.$1, other.$2);
        if (item != null) {
          await _addItem(items, item);
        }
      }
    }

    if (items.length < maxItems) {
      final commitments = await _browserRepository.list(
        MemoryEntityType.commitment,
        limit: maxItems,
      );
      for (final commitment in commitments) {
        if (items.length >= maxItems) break;
        if ((commitment.subtitle ?? '').trim().toLowerCase() != 'open')
          continue;
        await _addItem(items, commitment);
      }
    }

    final sorted = items.values.toList(growable: false)
      ..sort((left, right) {
        final byDate = right.createdAt.compareTo(left.createdAt);
        if (byDate != 0) return byDate;
        return left.source.stableKey.compareTo(right.source.stableKey);
      });
    return Tier3GenerationContext(sorted);
  }

  Future<void> _addItem(
    Map<String, Tier3ContextItem> items,
    MemoryListItem item,
  ) async {
    final source = InsightSourceReference(
      type: item.type,
      id: item.id,
      title: item.title,
    );
    if (items.containsKey(source.stableKey)) return;

    var content = item.title.trim();
    if (item.type == MemoryEntityType.capture) {
      final capture = await _browserRepository.getCaptureContent(item.id);
      final candidates = <String?>[
        capture?.summary,
        capture?.transcript,
        capture?.rawText,
      ];
      content = candidates
          .whereType<String>()
          .map((value) => value.trim())
          .firstWhere((value) => value.isNotEmpty, orElse: () => item.title);
    } else if ((item.subtitle ?? '').trim().isNotEmpty) {
      content = '${item.title}\nStatus: ${item.subtitle!.trim()}';
    }

    if (content.runes.length > maxContentCharacters) {
      content = String.fromCharCodes(content.runes.take(maxContentCharacters));
    }
    if (content.trim().isEmpty) return;

    items[source.stableKey] = Tier3ContextItem(
      source: source,
      content: content,
      createdAt: item.createdAt,
    );
  }

  (MemoryEntityType, String)? _otherSide(
    MemoryRelationshipView relationship,
    MemoryListItem anchor,
  ) {
    if (relationship.fromType == anchor.type.wireName &&
        relationship.fromId == anchor.id) {
      final type = MemoryEntityType.tryParse(relationship.toType);
      return type == null ? null : (type, relationship.toId);
    }
    if (relationship.toType == anchor.type.wireName &&
        relationship.toId == anchor.id) {
      final type = MemoryEntityType.tryParse(relationship.fromType);
      return type == null ? null : (type, relationship.fromId);
    }
    return null;
  }
}
