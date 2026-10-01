import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/trip_scope.dart';
import '../widgets/common_widgets.dart';
import 'place_detail_screen.dart';

class AllPlacesScreen extends StatefulWidget {
  const AllPlacesScreen({super.key});

  @override
  State<AllPlacesScreen> createState() => _AllPlacesScreenState();
}

class _AllPlacesScreenState extends State<AllPlacesScreen> {
  final _search = TextEditingController();
  String _area = 'Tutti';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final areas = ['Tutti', ...controller.publicData!.neighborhoods.map((n) => n.name)];
    final q = _search.text.trim().toLowerCase();
    final List<Place> filtered = controller.places.where((p) {
      final areaOk = _area == 'Tutti' || p.area == _area;
      final searchOk = q.isEmpty || '${p.name} ${p.area} ${p.type}'.toLowerCase().contains(q);
      return areaOk && searchOk;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text('DATABASE DEL VIAGGIO', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text('Tutto', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text('Cerca un luogo, filtra per quartiere e apri la scheda completa.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            TagPill('🔴 spesa prioritaria'),
            TagPill('🟡 opzionale'),
            TagPill('💚 gratis / smart'),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Cerca posto, quartiere, tipo…',
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: areas.map((area) {
              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: ChoiceChip(
                  label: Text(area),
                  selected: _area == area,
                  onSelected: (_) => setState(() => _area = area),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Nessun luogo corrisponde ai filtri.'),
            ),
          )
        else
          ...filtered.map((place) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PlaceCard(
                  place: place,
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id)),
                  ),
                ),
              )),
      ],
    );
  }
}
