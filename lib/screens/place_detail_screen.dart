import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/maps_service.dart';
import '../state/trip_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.placeId});
  final String placeId;

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final Place? place = controller.placeById(placeId);
    if (place == null) {
      return const Scaffold(body: Center(child: Text('Luogo non trovato.')));
    }
    final state = controller.stateFor('place', place.id);
    final group = controller.groupStates('place', place.id);
    final rated = group.where((x) => x.rating != null).toList();
    final avg = rated.isEmpty
        ? null
        : rated.map((e) => e.rating!).reduce((a, b) => a + b) / rated.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${place.type.toUpperCase()} · ${place.area.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                  ),
                  const SizedBox(height: 7),
                  Text(place.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(place.level, style: const TextStyle(color: Color(0xFF9E6A1F))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TagPill('🎟 ${place.price}'),
                      TagPill('⏱ ${place.duration}'),
                      TagPill(place.budget, background: const Color(0xFFFFF3DD)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(place.why),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: place.lat == null || place.lng == null
                              ? null
                              : () => MapsService().openCoordinates(place.lat!, place.lng!),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Google Maps'),
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
                          icon: Icon(
                            state?.completed == true
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                          ),
                          label: Text(state?.completed == true ? 'Visitato' : 'Segna visitato'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if ((place.details ?? '').isNotEmpty || place.highlights.isNotEmpty || (place.tips ?? '').isNotEmpty) ...[
            const SectionHeader(kicker: 'SCOPRI DI PIÙ', title: 'Storia, dettagli e consigli'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((place.details ?? '').isNotEmpty) Text(place.details!),
                    if (place.highlights.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Cosa guardare', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...place.highlights.map(
                        (h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  ', style: TextStyle(color: AppTheme.orange)),
                              Expanded(child: Text(h)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if ((place.tips ?? '').isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF5FB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD7E7F4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Consiglio smart', style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(place.tips!),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          SectionHeader(
            kicker: 'GRUPPO',
            title: group.isEmpty
                ? 'Ancora nessuna recensione'
                : '${group.length}/6 hanno completato${avg == null ? '' : ' · ★ ${avg.toStringAsFixed(1)}'}',
          ),
          if (group.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: group.map((review) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFFFE7D8),
                            child: Text(
                              controller.profileName(review.profileId).isNotEmpty ? controller.profileName(review.profileId)[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppTheme.orange,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.profileName(review.profileId),
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    if (review.rating != null)
                                      Text('★ ${review.rating}', style: const TextStyle(color: Color(0xFFD99919))),
                                  ],
                                ),
                                if ((review.note ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(review.note!, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
