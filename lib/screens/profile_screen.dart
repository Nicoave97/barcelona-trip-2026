import 'package:flutter/material.dart';

import '../state/trip_scope.dart';
import '../widgets/common_widgets.dart';
import 'admin_itinerary_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final user = controller.currentUser!;
    final myStates = controller.states.values.where((s) => s.profileId == user.id && s.completed).toList();
    final rated = myStates.where((s) => s.rating != null).toList();
    final avg = rated.isEmpty
        ? '—'
        : (rated.map((s) => s.rating!).reduce((a, b) => a + b) / rated.length).toStringAsFixed(1);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text('PROFILO', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(user.name, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatCard(label: 'Esperienze completate', value: '${myStates.length}'),
            StatCard(label: 'Media rating', value: avg),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  controller.online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  color: controller.online ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.online
                        ? 'Sincronizzazione online attiva: i dati sono condivisi tra i 6 profili.'
                        : 'Modalità cache: stai visualizzando l’ultima copia disponibile sul dispositivo.',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (controller.isAdmin) ...[
          const SectionHeader(kicker: 'SOLO NICOLA', title: 'Pannello Admin'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Puoi modificare l’itinerario condiviso. Gli altri profili possono solo usare checklist, rating, note e preferiti.'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminItineraryScreen()),
                      ),
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: const Text('Modifica itinerario'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () async {
            await controller.logout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Esci / cambia profilo'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
        ),
      ],
    );
  }
}
