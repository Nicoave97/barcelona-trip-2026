import 'package:flutter/material.dart';

import '../services/maps_service.dart';
import '../state/trip_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final data = controller.publicData!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text('MANGIARE A BARCELLONA', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text('Cibo & ristoranti', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text('Piatti da provare e locali utili lungo il vostro itinerario.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, icon: Icon(Icons.tapas_outlined), label: Text('Piatti')),
            ButtonSegment(value: 1, icon: Icon(Icons.restaurant_outlined), label: Text('Ristoranti')),
          ],
          selected: {_tab},
          onSelectionChanged: (value) => setState(() => _tab = value.first),
        ),
        const SizedBox(height: 14),
        if (_tab == 0)
          ...data.foods.map((food) {
            final state = controller.stateFor('food', food.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${food.kind} · ${food.price}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text(food.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 5),
                            Text(food.description, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.tonal(
                        onPressed: () => showEntityRatingDialog(
                          context,
                          title: food.name,
                          entityType: 'food',
                          entityKey: food.id,
                          verb: 'Provato',
                        ),
                        child: Text(state?.completed == true ? '✓ Provato' : 'Prova'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
        else
          ...data.restaurants.map((r) {
            final state = controller.stateFor('restaurant', r.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
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
                                Text(r.area, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(r.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('${r.level} · ${r.spend}/persona', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Preferito',
                            onPressed: () => controller.toggleFavorite('restaurant', r.id),
                            icon: Icon(
                              state?.favorite == true ? Icons.favorite : Icons.favorite_border,
                              color: state?.favorite == true ? AppTheme.orange : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(r.note),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: r.dishes.map((d) => TagPill(d)).toList()),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: r.lat == null || r.lng == null ? null : () => MapsService().openCoordinates(r.lat!, r.lng!),
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Maps'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () => showEntityRatingDialog(
                                context,
                                title: r.name,
                                entityType: 'restaurant',
                                entityKey: r.id,
                                verb: 'Mangiato qui',
                              ),
                              icon: Icon(state?.completed == true ? Icons.check_circle : Icons.circle_outlined),
                              label: Text(state?.completed == true ? 'Visitato' : 'Mangiato?'),
                            ),
                          ),
                        ],
                      ),
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
