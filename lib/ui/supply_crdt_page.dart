import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/ui_tokens.dart';
import '../crdt/conflict_record.dart';
import '../crdt/supply_models.dart';
import '../crdt/vector_clock.dart';
import '../core/rbac.dart';
import '../data/supply_repository.dart';
import '../features/identity/services/identity_service.dart';
import '../widgets/dd_page_intro.dart';

/// Step 3 — local OR-Set + vector clock (offline-first).
class SupplyCrdtPage extends StatefulWidget {
  const SupplyCrdtPage({super.key, required this.repository});

  final SupplyRepository repository;

  @override
  State<SupplyCrdtPage> createState() => _SupplyCrdtPageState();
}

class _SupplyCrdtPageState extends State<SupplyCrdtPage> {
  List<SupplyLine> _lines = [];
  List<CrdtConflict> _conflicts = [];
  VectorClock _clock = VectorClock();
  int? _deltaBytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final lines = await widget.repository.visibleLines();
      final clock = await widget.repository.currentClock();
      final conflicts = await widget.repository.pendingConflicts();
      final bytes = await widget.repository.estimateDeltaChunkBytes();
      if (mounted) {
        setState(() {
          _lines = lines;
          _clock = clock;
          _conflicts = conflicts;
          _deltaBytes = bytes;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showAddDialog() async {
    final sku = TextEditingController(text: 'SKU-${_lines.length + 1}');
    final desc = TextEditingController(text: 'Relief kit');
    final qty = TextEditingController(text: '10');
    CargoPriority priority = CargoPriority.p2;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: const Text('Add supply line'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sku,
                    decoration: const InputDecoration(labelText: 'SKU'),
                  ),
                  TextField(
                    controller: desc,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: qty,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Priority',
                      style: Theme.of(ctx).textTheme.labelLarge,
                    ),
                  ),
                  DropdownButton<CargoPriority>(
                    value: priority,
                    isExpanded: true,
                    items: CargoPriority.values
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setLocal(() => priority = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (ok == true && mounted) {
      final q = int.tryParse(qty.text.trim()) ?? 1;
      await widget.repository.addLine(
        sku: sku.text.trim(),
        description: desc.text.trim(),
        quantity: q,
        priority: priority,
      );
      await _reload();
    }
  }

  Future<void> _resolve(CrdtConflict c, {required bool pickLeft}) async {
    await widget.repository.resolveConflict(
      conflictId: c.id,
      pickLeft: pickLeft,
    );
    final id = context.read<IdentityService>();
    await id.audit.append(
      event: 'crdt_conflict_resolved',
      payload: {
        'conflict_id': c.id,
        'pick': pickLeft ? 'left' : 'right',
        'field': c.fieldName,
      },
    );
    await _reload();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conflict resolved & audited')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fabBottom = UiTokens.fabClearance(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'More',
                      onSelected: (v) async {
                        if (v == 'seed') {
                          try {
                            await widget.repository.seedDemoConflict();
                            await _reload();
                          } on RbacDeniedException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$e')),
                            );
                          }
                        }
                      },
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                          value: 'seed',
                          child: Text('Create training merge conflict'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiTokens.pageH),
                child: DdPageIntro(
                  title: 'Supply ledger',
                  description:
                      'Inventory merges across devices with vector clocks. Edits queue offline and sync on mesh.',
                ),
              ),
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: UiTokens.pageH),
                title: Text(
                  'Replica & vector clock',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 0, UiTokens.pageH, 12),
                    child: SelectableText(
                      'replica: ${widget.repository.replicaId}\n'
                      'clock: ${_clock.components}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (_deltaBytes != null)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: UiTokens.pageH),
                  leading: const Icon(Icons.data_object_outlined),
                  title: const Text('Last protobuf delta size'),
                  subtitle: Text(
                    '$_deltaBytes bytes (gRPC; no JSON on mesh)',
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiTokens.pageH),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_lines.length} visible line(s)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (_conflicts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiTokens.pageH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Merge required',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      for (final c in _conflicts)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Field ${c.fieldName}'),
                                Text('Replica A: ${c.leftValue} · ${c.leftClock.components}'),
                                Text('Replica B: ${c.rightValue} · ${c.rightClock.components}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    FilledButton.tonal(
                                      onPressed: () => _resolve(c, pickLeft: true),
                                      child: const Text('Keep A'),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton.tonal(
                                      onPressed: () => _resolve(c, pickLeft: false),
                                      child: const Text('Keep B'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    left: UiTokens.pageH,
                    right: UiTokens.pageH,
                    bottom: fabBottom + 8,
                  ),
                  itemCount: _lines.length,
                  itemBuilder: (context, i) {
                    final line = _lines[i];
                    return Dismissible(
                      key: ValueKey(line.uniqueTag),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
                      ),
                      onDismissed: (_) async {
                        await widget.repository.removeLine(
                          line.elementId,
                          line.uniqueTag,
                        );
                        await _reload();
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '${line.sku} × ${line.quantity}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${line.description} · ${line.priority.label} · ${line.locationNodeId}',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        if (!_loading)
          Positioned(
            right: UiTokens.pageH,
            bottom: fabBottom,
            child: FloatingActionButton(
              onPressed: _showAddDialog,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}
