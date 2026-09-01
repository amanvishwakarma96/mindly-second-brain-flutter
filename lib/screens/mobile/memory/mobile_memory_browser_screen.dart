import 'package:flutter/material.dart';
import 'package:mindly/features/memory/application/memory_browser_controller.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/screens/mobile/widgets/mobile_primary_navigation.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';

class MobileMemoryBrowserScreen extends StatefulWidget {
  const MobileMemoryBrowserScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-mobile-memory');

  final MemoryBrowserController? controller;

  @override
  State<MobileMemoryBrowserScreen> createState() =>
      _MobileMemoryBrowserScreenState();
}

class _MobileMemoryBrowserScreenState extends State<MobileMemoryBrowserScreen> {
  late final MemoryBrowserController _controller;
  late Future<List<MemoryListItem>> _itemsFuture;
  Future<List<HybridMemorySearchHit>>? _searchFuture;
  MemoryEntityType _type = MemoryEntityType.capture;
  CaptureBrowserFilter _filter = const CaptureBrowserFilter();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MemoryBrowserController.production();
    _itemsFuture = _loadItems();
  }

  Future<List<MemoryListItem>> _loadItems() {
    return _controller.list(_type, captureFilter: _filter);
  }

  void _refreshItems() {
    setState(() {
      _query = '';
      _searchFuture = null;
      _itemsFuture = _loadItems();
    });
  }

  void _runSearch(String value) {
    final query = value.trim();
    setState(() {
      _query = query;
      _searchFuture = query.isEmpty ? null : _controller.search(query: query);
      if (query.isEmpty) {
        _itemsFuture = _loadItems();
      }
    });
  }

  Future<void> _showFilters() async {
    var draft = _filter;
    final next = await showModalBottomSheet<CaptureBrowserFilter>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              MindlySpacing.lg,
              0,
              MindlySpacing.lg,
              MindlySpacing.lg,
            ),
            child: Column(
              key: const ValueKey<String>('mobile-memory-filter-sheet'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter memories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: MindlySpacing.md),
                Wrap(
                  spacing: MindlySpacing.sm,
                  runSpacing: MindlySpacing.sm,
                  children: [
                    FilterChip(
                      label: const Text('Work'),
                      selected: draft.context == 'work',
                      onSelected: (selected) => setSheetState(
                        () => draft = CaptureBrowserFilter(
                          context: selected ? 'work' : null,
                          isPinned: draft.isPinned,
                        ),
                      ),
                    ),
                    FilterChip(
                      label: const Text('Personal'),
                      selected: draft.context == 'personal',
                      onSelected: (selected) => setSheetState(
                        () => draft = CaptureBrowserFilter(
                          context: selected ? 'personal' : null,
                          isPinned: draft.isPinned,
                        ),
                      ),
                    ),
                    FilterChip(
                      label: const Text('Pinned'),
                      selected: draft.isPinned == true,
                      onSelected: (selected) => setSheetState(
                        () => draft = CaptureBrowserFilter(
                          context: draft.context,
                          isPinned: selected ? true : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MindlySpacing.lg),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setSheetState(
                        () => draft = const CaptureBrowserFilter(),
                      ),
                      child: const Text('Clear'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(draft),
                      child: const Text('Apply filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (next == null || !mounted) {
      return;
    }
    _filter = next;
    _refreshItems();
  }

  Future<void> _showDetail(MemoryEntityType type, String id) async {
    final detail = await _controller.detail(type, id);
    final graph = await _controller.graph(type, id);
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MindlySpacing.lg),
          child: detail == null
              ? const Text('This memory is no longer available.')
              : _MobileMemoryDetail(detail: detail, graph: graph),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: MobileMemoryBrowserScreen.screenKey,
      appBar: AppBar(title: const Text('Memory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MindlySpacing.md,
              MindlySpacing.sm,
              MindlySpacing.md,
              0,
            ),
            child: TextField(
              key: const ValueKey<String>('mobile-memory-search'),
              textInputAction: TextInputAction.search,
              onSubmitted: _runSearch,
              decoration: InputDecoration(
                hintText: 'Search what you remember',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () => _runSearch(''),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          const SizedBox(height: MindlySpacing.sm),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: MindlySpacing.md),
              children: MemoryEntityType.values
                  .map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: MindlySpacing.sm),
                      child: ChoiceChip(
                        label: Text(_label(type)),
                        selected: _type == type,
                        onSelected: (_) {
                          _type = type;
                          _filter = const CaptureBrowserFilter();
                          _refreshItems();
                        },
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          if (_query.isEmpty && _type == MemoryEntityType.capture)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MindlySpacing.md,
                MindlySpacing.sm,
                MindlySpacing.md,
                0,
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey<String>('mobile-memory-filter-button'),
                    onPressed: _showFilters,
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Filters'),
                  ),
                  const SizedBox(width: MindlySpacing.sm),
                  Expanded(
                    child: Text(
                      _activeFilterLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: MindlySpacing.sm),
          Expanded(
            child: _query.isEmpty
                ? FutureBuilder<List<MemoryListItem>>(
                    future: _itemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Memory could not be loaded.'),
                        );
                      }
                      final items = snapshot.data ?? const <MemoryListItem>[];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nothing here yet. Capture a thought first.',
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          final future = _loadItems();
                          setState(() => _itemsFuture = future);
                          await future;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(MindlySpacing.md),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: MindlySpacing.sm),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(_icon(item.type)),
                                title: Text(item.title),
                                subtitle: item.subtitle == null
                                    ? null
                                    : Text(item.subtitle!),
                                trailing: item.isPinned
                                    ? const Icon(Icons.push_pin_rounded)
                                    : const Icon(Icons.chevron_right_rounded),
                                onTap: () => _showDetail(item.type, item.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : FutureBuilder<List<HybridMemorySearchHit>>(
                    future: _searchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Search could not run.'),
                        );
                      }
                      final hits =
                          snapshot.data ?? const <HybridMemorySearchHit>[];
                      if (hits.isEmpty) {
                        return const Center(
                          child: Text('No matching memories.'),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(MindlySpacing.md),
                        itemCount: hits.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: MindlySpacing.sm),
                        itemBuilder: (context, index) {
                          final hit = hits[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(_icon(hit.type)),
                              title: Text(hit.content),
                              subtitle: Text(_label(hit.type)),
                              onTap: () => _showDetail(hit.type, hit.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const MobilePrimaryNavigation(selectedIndex: 2),
    );
  }

  String _activeFilterLabel() {
    final labels = <String>[];
    if (_filter.context == 'work') labels.add('Work');
    if (_filter.context == 'personal') labels.add('Personal');
    if (_filter.isPinned == true) labels.add('Pinned');
    return labels.isEmpty ? 'Showing all captures' : labels.join(' · ');
  }

  String _label(MemoryEntityType type) => switch (type) {
    MemoryEntityType.capture => 'Captures',
    MemoryEntityType.person => 'People',
    MemoryEntityType.topic => 'Topics',
    MemoryEntityType.commitment => 'Commitments',
  };

  IconData _icon(MemoryEntityType type) => switch (type) {
    MemoryEntityType.capture => Icons.notes_rounded,
    MemoryEntityType.person => Icons.person_rounded,
    MemoryEntityType.topic => Icons.sell_rounded,
    MemoryEntityType.commitment => Icons.task_alt_rounded,
  };
}

class _MobileMemoryDetail extends StatelessWidget {
  const _MobileMemoryDetail({required this.detail, required this.graph});

  final MemoryDetail detail;
  final MemoryGraphNeighborhood? graph;

  @override
  Widget build(BuildContext context) {
    final text = [
      detail.summary,
      detail.transcript,
      detail.rawText,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    final nodes =
        graph?.nodes.where((node) => node.depth > 0).toList() ?? const [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.item.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: MindlySpacing.md),
          for (final value in text) ...[
            Text(value),
            const SizedBox(height: MindlySpacing.sm),
          ],
          Text('Connections', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: MindlySpacing.sm),
          if (nodes.isEmpty)
            const Text('No connected memories yet.')
          else
            Wrap(
              spacing: MindlySpacing.sm,
              runSpacing: MindlySpacing.sm,
              children: nodes
                  .map((node) => Chip(label: Text(node.item.title)))
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}
