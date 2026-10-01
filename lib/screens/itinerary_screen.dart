import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/maps_service.dart';
import '../state/trip_scope.dart';
import '../widgets/common_widgets.dart';
import 'admin_itinerary_screen.dart';
import 'place_detail_screen.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final data = controller.publicData!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text('PIANO CONDIVISO', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text('Itinerario', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text('La stessa checklist è visibile in tutta l’app e viene sincronizzata tra i 6 profili.', style: Theme.of(context).textTheme.bodySmall),
        if (controller.isAdmin) ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminItineraryScreen()),
            ),
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('Nicola · modifica attività e orari'),
          ),
        ],
        const SizedBox(height: 14),
        ...data.dayMeta.map((meta) {
          final items = controller.itemsForDay(meta.day);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ExpansionTile(
                initiallyExpanded: meta.day == data.dayMeta.first.day,
                tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                title: Text(meta.day, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(meta.title),
                trailing: TagPill(meta.tag),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('💡 ${meta.note}', style: const TextStyle(color: Color(0xFF88611F), fontSize: 12)),
                  ),
                  ...items.map((item) => _ItineraryRow(item: item)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ItineraryRow extends StatelessWidget {
  const _ItineraryRow({required this.item});
  final ItineraryItem item;

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final place = controller.placeById(item.placeId);
    final state = place == null ? null : controller.stateFor('place', place.id);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0E8DC))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              item.timeLabel ?? '—',
              style: const TextStyle(color: Color(0xFFB96D32), fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: place == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id)),
                          ),
                  child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                if ((item.travel ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF5FB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD7E7F4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🚇 COME ARRIVARE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF3F7CAC))),
                        const SizedBox(height: 3),
                        Text(item.travel!, style: const TextStyle(fontSize: 12)),
                        if ((item.travelTime ?? '').isNotEmpty) Text('⏱ ${item.travelTime}', style: Theme.of(context).textTheme.bodySmall),
                        if ((item.travelTip ?? '').isNotEmpty) Text('💡 ${item.travelTip}', style: const TextStyle(fontSize: 11, color: Color(0xFFA06B21))),
                      ],
                    ),
                  ),
                ],
                if ((item.optionalNote ?? '').isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text('↪ ${item.optionalNote}', style: const TextStyle(fontSize: 11, color: Color(0xFF8B6625))),
                ],
                if (place != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      TagPill('🎟 ${place.price}'),
                      TagPill('⏱ ${place.duration}'),
                      TagPill(place.level),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (place.lat != null && place.lng != null)
                        OutlinedButton.icon(
                          onPressed: () => MapsService().openCoordinates(place.lat!, place.lng!),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Maps'),
                        ),
                      FilledButton.tonalIcon(
                        onPressed: () => showEntityRatingDialog(
                          context,
                          title: place.name,
                          entityType: 'place',
                          entityKey: place.id,
                          verb: 'Visitato',
                        ),
                        icon: Icon(state?.completed == true ? Icons.check_circle : Icons.circle_outlined, size: 18),
                        label: Text(state?.completed == true ? 'Visitato' : 'Segna'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
