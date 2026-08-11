import 'package:flutter/material.dart';
import 'package:mindly/features/memory/application/memory_browser_controller.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/shared/design_tokens/mindly_spacing.dart';
import 'package:mindly/shared/widgets/mindly_brand_badge.dart';

class WebMemoryBrowserScreen extends StatefulWidget {
  const WebMemoryBrowserScreen({super.key, this.controller});

  static const screenKey = ValueKey<String>('screen-web-memory');

  final MemoryBrowserController? controller;

  @override
  State<WebMemoryBrowserScreen> createState() => _WebMemoryBrowserScreenState();
}

class _WebMemoryBrowserScreenState extends State<WebMemoryBrowserScreen> {
  late final MemoryBrowserController _controller;
  late Future<List<MemoryListItem>> _itemsFuture;
  Future<List<HybridMemorySearchHit>>? _searchFuture;
  MemoryEntityType _type = MemoryEntityType.capture;
  String _query = '';
  MemoryListItem? _selected;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MemoryBrowserController.production();
    _itemsFuture = _controller.list(_type);
  }

  void _selectType(MemoryEntityType type) {
    setState(() {
      _type = type;
      _query = '';
      _searchFuture = null;
      _selected = null;
      _itemsFuture = _controller.list(type);
    });
  }

  void _runSearch(String value) {
    final query = value.trim();
    setState(() {
      _query = query;
      _selected = null;
      _searchFuture = query.isEmpty ? null : _controller.search(query: query);
      if (query.isEmpty) {
        _itemsFuture = _controller.list(_type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: WebMemoryBrowserScreen.screenKey,
      appBar: AppBar(
        title: const Text('Memory · Mindly'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth < 800
            ? _buildNarrow(context)
            : _buildWide(context),
      ),
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 210,
          child: Padding(
            padding: const EdgeInsets.all(MindlySpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MindlyBrandBadge(),
                const SizedBox(height: MindlySpacing.xl),
                for (final type in MemoryEntityType.values)
                  TextButton.icon(
                    onPressed: () => _selectType(type),
                    icon: Icon(_icon(type)),
                    label: Text(_label(type)),
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
                  key: const ValueKey<String>('web-memory-search'),
                  onSubmitted: _runSearch,
                  decoration: InputDecoration(
                    hintText: 'Search this browser’s local memory',
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
              Expanded(child: _buildResults()),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: _selected == null
              ? const Center(child: Text('Select a memory to see its graph.'))
              : _WebDetailPane(controller: _controller, item: _selected!),
        ),
      ],
    );
  }

  Widget _buildNarrow(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(MindlySpacing.md),
          child: TextField(
            key: const ValueKey<String>('web-memory-search-narrow'),
            onSubmitted: _runSearch,
            decoration: const InputDecoration(
              hintText: 'Search local memory',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
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
                      selected: type == _type && _query.isEmpty,
                      onSelected: (_) => _selectType(type),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: MindlySpacing.sm),
        Expanded(child: _buildResults(narrow: true)),
      ],
    );
  }

  Widget _buildResults({bool narrow = false}) {
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
            padding: const EdgeInsets.all(MindlySpacing.md),
            itemCount: hits.length,
            itemBuilder: (context, index) {
              final hit = hits[index];
              return Card(
                child: ListTile(
                  leading: Icon(_icon(hit.type)),
                  title: Text(hit.content),
                  subtitle: Text(_label(hit.type)),
                  onTap: () async {
                    final detail = await _controller.detail(hit.type, hit.id);
                    if (!mounted || detail == null) {
                      return;
                    }
                    if (narrow) {
                      await _showNarrowDetail(detail.item);
                    } else {
                      setState(() => _selected = detail.item);
                    }
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
        return ListView.builder(
          padding: const EdgeInsets.all(MindlySpacing.md),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                leading: Icon(_icon(item.type)),
                title: Text(item.title),
                subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                onTap: () => narrow
                    ? _showNarrowDetail(item)
                    : setState(() => _selected = item),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showNarrowDetail(MemoryListItem item) async {
    final detail = await _controller.detail(item.type, item.id);
    final graph = await _controller.graph(item.type, item.id);
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(detail?.item.title ?? 'Memory unavailable'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (detail?.summary?.trim().isNotEmpty == true)
                  Text(detail!.summary!),
                if (detail?.transcript?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: MindlySpacing.sm),
                  Text(detail!.transcript!),
                ],
                if (detail?.rawText?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: MindlySpacing.sm),
                  Text(detail!.rawText!),
                ],
                const SizedBox(height: MindlySpacing.md),
                Text('Connected: ${_connectedCount(graph)}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int _connectedCount(MemoryGraphNeighborhood? graph) {
    return graph?.nodes.where((node) => node.depth > 0).length ?? 0;
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

class _WebDetailPane extends StatelessWidget {
  const _WebDetailPane({required this.controller, required this.item});

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
        final detail = snapshot.data?.$1;
        final graph = snapshot.data?.$2;
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
            if (detail.summary?.trim().isNotEmpty == true)
              Text(detail.summary!),
            if (detail.transcript?.trim().isNotEmpty == true) ...[
              const SizedBox(height: MindlySpacing.sm),
              Text(detail.transcript!),
            ],
            if (detail.rawText?.trim().isNotEmpty == true) ...[
              const SizedBox(height: MindlySpacing.sm),
              Text(detail.rawText!),
            ],
            const SizedBox(height: MindlySpacing.lg),
            Text('Graph', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: MindlySpacing.sm),
            if (connected.isEmpty)
              const Text('No connected memories yet.')
            else
              for (final node in connected)
                ListTile(
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
    return (
      await controller.detail(item.type, item.id),
      await controller.graph(item.type, item.id),
    );
  }
}
