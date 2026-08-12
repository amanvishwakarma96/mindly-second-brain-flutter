import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindly/features/memory/application/memory_browser_controller.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class DesktopMemoryBrowserScreen extends StatefulWidget {
  const DesktopMemoryBrowserScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-desktop-memory');

  final MemoryBrowserController? controller;

  @override
  State<DesktopMemoryBrowserScreen> createState() =>
      _DesktopMemoryBrowserScreenState();
}

class _DesktopMemoryBrowserScreenState
    extends State<DesktopMemoryBrowserScreen> {
  late final MemoryBrowserController _controller;
  late Future<List<MemoryListItem>> _itemsFuture;
  Future<List<HybridMemorySearchHit>>? _searchFuture;
  MemoryEntityType _type = MemoryEntityType.capture;
  CaptureBrowserFilter _filter = const CaptureBrowserFilter();
  String _query = '';
  MemoryListItem? _selected;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MemoryBrowserController.production();
    _itemsFuture = _loadItems();
  }

  Future<List<MemoryListItem>> _loadItems() {
    return _controller.list(_type, captureFilter: _filter);
  }

  void _selectType(MemoryEntityType type) {
    setState(() {
      _type = type;
      _filter = const CaptureBrowserFilter();
      _query = '';
      _searchFuture = null;
      _selected = null;
      _itemsFuture = _loadItems();
    });
  }

  void _runSearch(String value) {
    final query = value.trim();
    setState(() {
      _query = query;
      _selected = null;
      _searchFuture = query.isEmpty ? null : _controller.search(query: query);
      if (query.isEmpty) {
        _itemsFuture = _loadItems();
      }
    });
  }

  void _moveSelection(List<MemoryListItem> items, int delta) {
    if (items.isEmpty) return;
    final current = _selected == null
        ? -1
        : items.indexWhere((item) => item.id == _selected!.id);
    final next = (current + delta).clamp(0, items.length - 1).toInt();
    setState(() => _selected = items[next]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: DesktopMemoryBrowserScreen.screenKey,
      body: Row(
        children: [
          SizedBox(
            key: const ValueKey<String>('desktop-memory-sidebar'),
            width: 220,
            child: Padding(
              padding: const EdgeInsets.all(MindlySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MindlyBrandBadge(),
                  const SizedBox(height: MindlySpacing.xl),
                  Text('Memory', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: MindlySpacing.md),
                  for (final type in MemoryEntityType.values)
                    ListTile(
                      selected: _type == type && _query.isEmpty,
                      leading: Icon(_icon(type)),
                      title: Text(_label(type)),
                      onTap: () => _selectType(type),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(MindlySpacing.lg),
                  child: TextField(
                    key: const ValueKey<String>('desktop-memory-search'),
                    onSubmitted: _runSearch,
                    decoration: InputDecoration(
                      hintText: 'Search local memory',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () => _runSearch(''),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                if (_query.isEmpty && _type == MemoryEntityType.capture)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MindlySpacing.lg,
                    ),
                    child: Wrap(
                      spacing: MindlySpacing.sm,
                      children: [
                        FilterChip(
                          label: const Text('Work'),
                          selected: _filter.context == 'work',
                          onSelected: (value) =>
                              _setContext(value ? 'work' : null),
                        ),
                        FilterChip(
                          label: const Text('Personal'),
                          selected: _filter.context == 'personal',
                          onSelected: (value) =>
                              _setContext(value ? 'personal' : null),
                        ),
                        FilterChip(
                          label: const Text('Pinned'),
                          selected: _filter.isPinned == true,
                          onSelected: (value) {
                            setState(() {
                              _filter = CaptureBrowserFilter(
                                context: _filter.context,
                                isPinned: value ? true : null,
                              );
                              _itemsFuture = _loadItems();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: MindlySpacing.sm),
                Expanded(child: _buildResults()),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            key: const ValueKey<String>('desktop-memory-detail-pane'),
            flex: 2,
            child: _selected == null
                ? const Center(
                    child: Text(
                      'Choose a memory to inspect it. Use ↑ and ↓ to move through the list.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : _DesktopDetailPane(controller: _controller, item: _selected!),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isNotEmpty) {
      return FutureBuilder<List<HybridMemorySearchHit>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Search could not run.'));
          }
          final hits = snapshot.data ?? const <HybridMemorySearchHit>[];
          if (hits.isEmpty) {
            return const Center(child: Text('No matching memories.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(MindlySpacing.lg),
            itemCount: hits.length,
            itemBuilder: (context, index) {
              final hit = hits[index];
              return Card(
                child: ListTile(
                  leading: Icon(_icon(hit.type)),
                  title: Text(hit.content),
                  subtitle: Text(_label(hit.type)),
                  onTap: () async {
                    final item = await _controller.detail(hit.type, hit.id);
                    if (!mounted || item == null) {
                      return;
                    }
                    setState(() => _selected = item.item);
                  },
                ),
              );
            },
          );
        },
      );
    }

    return FutureBuilder<List<MemoryListItem>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Memory could not be loaded.'));
        }
        final items = snapshot.data ?? const <MemoryListItem>[];
        if (items.isEmpty) {
          return const Center(child: Text('Nothing here yet.'));
        }
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                _moveSelection(items, 1),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                _moveSelection(items, -1),
          },
          child: Focus(
            autofocus: true,
            child: ListView.builder(
              key: const ValueKey<String>('desktop-memory-master-list'),
              padding: const EdgeInsets.all(MindlySpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    selected: _selected?.id == item.id,
                    leading: Icon(_icon(item.type)),
                    title: Text(item.title),
                    subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                    trailing: item.isPinned
                        ? const Icon(Icons.push_pin_rounded)
                        : null,
                    onTap: () => setState(() => _selected = item),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _setContext(String? context) {
    setState(() {
      _filter = CaptureBrowserFilter(
        context: context,
        isPinned: _filter.isPinned,
      );
      _itemsFuture = _loadItems();
    });
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

class _DesktopDetailPane extends StatelessWidget {
  const _DesktopDetailPane({required this.controller, required this.item});

  final MemoryBrowserController controller;
  final MemoryListItem item;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(MemoryDetail?, MemoryGraphNeighborhood?)>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        final detail = data?.$1;
        final graph = data?.$2;
        if (detail == null) {
          return const Center(child: Text('This memory is unavailable.'));
        }
        final connected =
            graph?.nodes.where((node) => node.depth > 0).toList() ?? const [];
        return ListView(
          padding: const EdgeInsets.all(MindlySpacing.lg),
          children: [
            Text(
              detail.item.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: MindlySpacing.md),
            if (detail.summary?.trim().isNotEmpty == true) ...[
              const Text('Summary'),
              Text(detail.summary!),
              const SizedBox(height: MindlySpacing.md),
            ],
            if (detail.transcript?.trim().isNotEmpty == true) ...[
              const Text('Transcript'),
              Text(detail.transcript!),
              const SizedBox(height: MindlySpacing.md),
            ],
            if (detail.rawText?.trim().isNotEmpty == true) ...[
              const Text('Source'),
              Text(detail.rawText!),
              const SizedBox(height: MindlySpacing.md),
            ],
            Text('Graph', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: MindlySpacing.sm),
            if (connected.isEmpty)
              const Text('No connected memories yet.')
            else
              for (final node in connected)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.hub_rounded),
                  title: Text(node.item.title),
                  subtitle: Text('Depth ${node.depth}'),
                ),
          ],
        );
      },
    );
  }

  Future<(MemoryDetail?, MemoryGraphNeighborhood?)> _load() async {
    final detail = await controller.detail(item.type, item.id);
    final graph = await controller.graph(item.type, item.id);
    return (detail, graph);
  }
}
