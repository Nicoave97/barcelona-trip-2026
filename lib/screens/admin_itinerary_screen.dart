import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/trip_scope.dart';

class AdminItineraryScreen extends StatefulWidget {
  const AdminItineraryScreen({super.key});

  @override
  State<AdminItineraryScreen> createState() => _AdminItineraryScreenState();
}

class _AdminItineraryScreenState extends State<AdminItineraryScreen> {
  late List<ItineraryItem> _items;
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _items = List<ItineraryItem>.from(TripScope.of(context).itineraryItems);
      _initialized = true;
    }
  }

  List<ItineraryItem> _forDay(String day) => _items.where((x) => x.dayKey == day).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  Future<void> _edit(ItineraryItem? old, String day) async {
    final time = TextEditingController(text: old?.timeLabel ?? '12:00');
    final title = TextEditingController(text: old?.title ?? '');
    final optional = TextEditingController(text: old?.optionalNote ?? '');
    final controller = TripScope.of(context);
    String? placeId = old?.placeId;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(old == null ? 'Nuova attività · $day' : 'Modifica attività · $day'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: time, decoration: const InputDecoration(labelText: 'Orario / fascia')),
                const SizedBox(height: 10),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Attività')),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setLocal) => DropdownButtonFormField<String?>(
                    value: placeId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Collega a un luogo (opzionale)'),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Nessun luogo')),
                      ...controller.places.map((p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.name))),
                    ],
                    onChanged: (value) => setLocal(() => placeId = value),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: optional,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Nota / alternativa'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Salva')),
        ],
      ),
    );
    if (result != true || title.text.trim().isEmpty) return;

    setState(() {
      if (old != null) {
        final index = _items.indexWhere((x) => x.id == old.id);
        _items[index] = old.copyWith(
          timeLabel: time.text.trim(),
          title: title.text.trim(),
          placeId: placeId,
          optionalNote: optional.text.trim(),
        );
      } else {
        final order = _forDay(day).length;
        _items.add(
          ItineraryItem(
            id: 'local-${DateTime.now().microsecondsSinceEpoch}',
            dayKey: day,
            sortOrder: order,
            timeLabel: time.text.trim(),
            title: title.text.trim(),
            placeId: placeId,
            optionalNote: optional.text.trim(),
            kind: placeId == null ? 'custom' : null,
          ),
        );
      }
    });
  }

  void _delete(ItineraryItem item) {
    setState(() => _items.removeWhere((x) => x.id == item.id));
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    try {
      final normalized = <ItineraryItem>[];
      final days = TripScope.of(context).publicData!.dayMeta.map((d) => d.day);
      for (final day in days) {
        final list = _forDay(day);
        for (var i = 0; i < list.length; i++) {
          normalized.add(list[i].copyWith(sortOrder: i));
        }
      }
      await TripScope.of(context).replaceItinerary(normalized);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Itinerario sincronizzato.')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    if (!controller.isAdmin) {
      return const Scaffold(body: Center(child: Text('Accesso riservato all’admin.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Modifica itinerario')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _saveAll,
        icon: _saving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.cloud_upload_outlined),
        label: const Text('Salva online'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: controller.publicData!.dayMeta.map((meta) {
          final list = _forDay(meta.day);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meta.day, style: Theme.of(context).textTheme.titleLarge),
                              Text(meta.title, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _edit(null, meta.day),
                          icon: const Icon(Icons.add),
                          label: const Text('Attività'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...list.map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: SizedBox(
                            width: 65,
                            child: Text(item.timeLabel ?? '—', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                          title: Text(item.title),
                          subtitle: item.placeId == null ? null : Text('🔗 ${controller.placeById(item.placeId)?.name ?? item.placeId}'),
                          trailing: Wrap(
                            children: [
                              IconButton(onPressed: () => _edit(item, meta.day), icon: const Icon(Icons.edit_outlined)),
                              IconButton(onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
