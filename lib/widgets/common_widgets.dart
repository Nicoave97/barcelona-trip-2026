import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/maps_service.dart';
import '../state/trip_controller.dart';
import '../state/trip_scope.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.kicker, required this.title, this.trailing});
  final String kicker;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 26, 2, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF9F6F1A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF20415B),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill(this.text, {super.key, this.background, this.foreground});
  final String text;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? const Color(0xFFF6F2EA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFECE4D9)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground ?? const Color(0xFF566273),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class EntityRatingDialog extends StatefulWidget {
  const EntityRatingDialog({
    super.key,
    required this.title,
    required this.entityType,
    required this.entityKey,
    required this.verb,
  });

  final String title;
  final String entityType;
  final String entityKey;
  final String verb;

  @override
  State<EntityRatingDialog> createState() => _EntityRatingDialogState();
}

class _EntityRatingDialogState extends State<EntityRatingDialog> {
  late final TextEditingController _noteController;
  int _rating = 0;
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final controller = TripScope.of(context);
    final old = controller.stateFor(widget.entityType, widget.entityKey);
    _rating = old?.rating ?? 0;
    _noteController = TextEditingController(text: old?.note ?? '');
    _initialized = true;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scegli prima un voto da 1 a 5.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final controller = TripScope.of(context);
      await controller.saveState(
        entityType: widget.entityType,
        entityKey: widget.entityKey,
        completed: true,
        rating: _rating,
        note: _noteController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    try {
      await TripScope.of(context).deleteState(widget.entityType, widget.entityKey);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final old = TripScope.of(context).stateFor(widget.entityType, widget.entityKey);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.verb}. Che voto gli dai?'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 3,
              children: List.generate(5, (index) {
                final value = index + 1;
                return IconButton(
                  onPressed: _saving ? null : () => setState(() => _rating = value),
                  iconSize: 34,
                  icon: Icon(
                    value <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: value <= _rating ? const Color(0xFFE0A51F) : Colors.grey.shade400,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nota per il gruppo',
                hintText: 'Es. molto bello al tramonto…',
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (old?.completed == true)
          TextButton(
            onPressed: _saving ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Elimina visita'),
          ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Salva'),
        ),
      ],
    );
  }
}

Future<void> showEntityRatingDialog(
  BuildContext context, {
  required String title,
  required String entityType,
  required String entityKey,
  required String verb,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => TripScope(
      controller: TripScope.of(context),
      child: EntityRatingDialog(
        title: title,
        entityType: entityType,
        entityKey: entityKey,
        verb: verb,
      ),
    ),
  );
}

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onOpen,
  });

  final Place place;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final state = controller.stateFor('place', place.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${place.type} · ${place.area}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(place.name, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                  Text(
                    place.level,
                    style: const TextStyle(
                      color: Color(0xFF9E6A1F),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  TagPill('🎟 ${place.price}'),
                  TagPill('⏱ ${place.duration}'),
                  TagPill(place.budget),
                ],
              ),
              const SizedBox(height: 10),
              Text(place.why, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: place.lat == null || place.lng == null
                          ? null
                          : () async {
                              try {
                                await MapsService().openCoordinates(place.lat!, place.lng!);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$e')),
                                );
                              }
                            },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Maps'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => showEntityRatingDialog(
                        context,
                        title: place.name,
                        entityType: 'place',
                        entityKey: place.id,
                        verb: 'Visitato',
                      ),
                      icon: Icon(state?.completed == true ? Icons.check_circle : Icons.circle_outlined),
                      label: Text(state?.completed == true ? 'Visitato' : 'Visitato?'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroPanel extends StatelessWidget {
  const HeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final data = controller.publicData!;
    final home = controller.privateConfig?.accommodation;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8DDCF)),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7EB), Color(0xFFF0F7FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CITY TRIP · 6 AMICI',
                  style: TextStyle(
                    color: Color(0xFF9F6F1A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  home?.name ?? 'Alloggio del gruppo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                if ((home?.address ?? '').isNotEmpty)
                  Text(home!.address, style: const TextStyle(color: Color(0xFF4F6072))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TagPill('📆 ${data.dates}', background: Colors.white),
                    if ((home?.metro ?? '').isNotEmpty)
                      TagPill('🚇 ${home!.metro}', background: Colors.white),
                    const TagPill('💡 itinerario smart + budget', background: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          if (home?.lat != null && home?.lng != null) ...[
            const SizedBox(width: 14),
            IconButton.filled(
              tooltip: 'Apri casa su Maps',
              onPressed: () => MapsService().openCoordinates(home!.lat!, home.lng!),
              icon: const Icon(Icons.map_outlined),
              style: IconButton.styleFrom(backgroundColor: AppTheme.blue),
            ),
          ],
        ],
      ),
    );
  }
}
