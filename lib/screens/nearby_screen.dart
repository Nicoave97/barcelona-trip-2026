import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/location_service.dart';
import '../state/trip_scope.dart';
import '../widgets/common_widgets.dart';
import 'place_detail_screen.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyEntry {
  const _NearbyEntry(this.place, this.km);
  final Place place;
  final double km;
}

class _NearbyScreenState extends State<NearbyScreen> {
  final _location = LocationService();
  List<_NearbyEntry>? _entries;
  bool _loading = false;
  String? _error;
  double _maxKm = 2;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final controller = TripScope.of(context);
      final pos = await _location.currentPosition();
      final entries = controller.places
          .where((p) => p.lat != null && p.lng != null)
          .map(
            (p) => _NearbyEntry(
              p,
              _location.distanceKm(
                fromLat: pos.latitude,
                fromLng: pos.longitude,
                toLat: p.lat!,
                toLng: p.lng!,
              ),
            ),
          )
          .toList()
        ..sort((a, b) => a.km.compareTo(b.km));
      if (mounted) setState(() => _entries = entries);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = (_entries ?? const <_NearbyEntry>[]).where((e) => e.km <= _maxKm).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text('GPS', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text('Vicino a me', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text('Ordina i luoghi del viaggio in base alla tua posizione. Il GPS non viene condiviso con il gruppo.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.my_location),
                    label: Text(_loading ? 'Calcolo posizione…' : 'Usa la mia posizione'),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: .5, label: Text('<500 m')),
                    ButtonSegment(value: 1, label: Text('<1 km')),
                    ButtonSegment(value: 2, label: Text('<2 km')),
                  ],
                  selected: {_maxKm},
                  onSelectionChanged: (s) => setState(() => _maxKm = s.first),
                ),
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ),
          ),
        ],
        if (_entries != null) ...[
          SectionHeader(kicker: 'RISULTATI', title: '${filtered.length} posti entro ${_maxKm == .5 ? '500 m' : '${_maxKm.toStringAsFixed(0)} km'}'),
          if (filtered.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Nessun luogo del viaggio in questo raggio.')))
          else
            ...filtered.map((entry) {
              final state = TripScope.of(context).stateFor('place', entry.place.id);
              final distance = entry.km < 1 ? '${(entry.km * 1000).round()} m' : '${entry.km.toStringAsFixed(1)} km';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: entry.place.id)),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEEF5FB),
                      child: Text('${filtered.indexOf(entry) + 1}'),
                    ),
                    title: Text(entry.place.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${entry.place.area} · ${entry.place.level}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(distance, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Icon(state?.completed == true ? Icons.check_circle : Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ],
    );
  }
}
