import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/trip_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'place_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  int _todayIndex() {
    final now = DateTime.now();
    final tripStart = DateTime(2026, 10, 8);
    final day2 = DateTime(2026, 10, 9);
    final day3 = DateTime(2026, 10, 10);
    final day4 = DateTime(2026, 10, 11);
    if (now.isBefore(day2)) return 0;
    if (now.isBefore(day3)) return 1;
    if (now.isBefore(day4)) return 2;
    if (now.year == day4.year && now.month == day4.month && now.day == day4.day) return 3;
    return now.isBefore(tripStart) ? 0 : 3;
  }

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final data = controller.publicData!;
    final candidate = _todayIndex();
    final index = candidate < 0
        ? 0
        : candidate >= data.dayMeta.length
            ? data.dayMeta.length - 1
            : candidate;
    final meta = data.dayMeta[index];
    final items = controller.itemsForDay(meta.day);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        const HeroPanel(),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width < 540 ? 2 : 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatCard(label: 'Luoghi visitati', value: '${controller.completedCount('place')}/${controller.places.length}'),
            StatCard(label: 'Cibo provato', value: '${controller.completedCount('food')}/${data.foods.length}'),
            StatCard(label: 'Locali provati', value: '${controller.completedCount('restaurant')}/${data.restaurants.length}'),
            StatCard(label: 'Preferiti', value: '${controller.favoriteCount()}'),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: MediaQuery.sizeOf(context).width < 520 ? 1.85 : 2.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _QuickAction(icon: Icons.near_me_outlined, title: 'Vicino a me', subtitle: 'GPS e distanze', onTap: () => onNavigate(3)),
            _QuickAction(icon: Icons.location_city_outlined, title: 'Quartieri', subtitle: 'Zone e posti', onTap: () => onNavigate(2)),
            _QuickAction(icon: Icons.restaurant_outlined, title: 'Cibo & locali', subtitle: 'Piatti e prezzi', onTap: () => onNavigate(4)),
            _QuickAction(icon: Icons.calendar_month_outlined, title: 'Itinerario', subtitle: 'Programma condiviso', onTap: () => onNavigate(1)),
          ],
        ),
        SectionHeader(
          kicker: 'PROGRAMMA',
          title: meta.day,
          trailing: TagPill(meta.tag, background: const Color(0xFFFFF3DD), foreground: const Color(0xFF945D12)),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meta.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text(meta.note, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ...items.take(8).map((item) => _TimelinePreview(item: item)),
                if (items.length > 8)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => onNavigate(1),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text('Vedi tutte le ${items.length} attività'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SectionHeader(kicker: 'PRIMA DI PARTIRE', title: 'Promemoria utili'),
        const _Reminder(title: 'La Pedrera Night', subtitle: 'Verificare prenotazione e orario definitivo', icon: Icons.nightlight_outlined, color: AppTheme.orange),
        const SizedBox(height: 8),
        const _Reminder(title: 'Parc Güell', subtitle: 'Ingresso a orario: controllare il biglietto prima di partire', icon: Icons.park_outlined, color: AppTheme.green),
        const SizedBox(height: 8),
        const _Reminder(title: 'Razzmatazz', subtitle: 'Controllare evento e prevendita della serata', icon: Icons.music_note_outlined, color: AppTheme.blue),
        const SectionHeader(kicker: 'TRASPORTI', title: 'Aeroporto ↔ casa'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✈️ Percorso principale', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(controller.privateConfig?.airport.out ?? 'Caricamento informazioni…'),
                if ((controller.privateConfig?.airport.t2 ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(controller.privateConfig!.airport.t2, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.orange),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
}

class _TimelinePreview extends StatelessWidget {
  const _TimelinePreview({required this.item});
  final ItineraryItem item;

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final place = controller.placeById(item.placeId);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
            child: InkWell(
              onTap: place == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id)),
                      ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if ((item.travelTime ?? '').isNotEmpty)
                    Text('⏱ ${item.travelTime}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Reminder extends StatelessWidget {
  const _Reminder({required this.title, required this.subtitle, required this.icon, required this.color});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: .11),
            foregroundColor: color,
            child: Icon(icon),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle),
        ),
      );
}
