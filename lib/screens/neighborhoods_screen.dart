import 'package:flutter/material.dart';

import '../state/trip_scope.dart';
import 'place_detail_screen.dart';

class NeighborhoodsScreen extends StatelessWidget {
  const NeighborhoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final data = controller.publicData!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text('ESPLORA LIBERAMENTE', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text('Quartieri', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text('Le zone più utili per il vostro viaggio, con posti e locali collegati.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        ...data.neighborhoods.map((area) {
          final places = area.placeIds.map(controller.placeById).whereType().toList();
          final restaurants = data.restaurants.where((r) => r.area == area.name).take(4).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3DD),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(child: Text(area.icon, style: const TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(area.name, style: Theme.of(context).textTheme.titleMedium),
                              Text(area.distance, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(area.description, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    ...places.map((place) {
                      final state = controller.stateFor('place', place.id);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          state?.completed == true ? Icons.check_circle : Icons.circle_outlined,
                          color: state?.completed == true ? Colors.green : Colors.grey.shade500,
                        ),
                        title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${place.level} · ${place.price}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id)),
                        ),
                      );
                    }),
                    if (restaurants.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text('🍽️ Ristoranti suggeriti', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      ...restaurants.map((r) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(r.name),
                            subtitle: Text('${r.spend} · ${r.level}'),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
