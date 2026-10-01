import 'package:flutter/material.dart';

import '../state/trip_scope.dart';
import '../theme/app_theme.dart';
import 'all_places_screen.dart';
import 'food_screen.dart';
import 'home_screen.dart';
import 'itinerary_screen.dart';
import 'nearby_screen.dart';
import 'neighborhoods_screen.dart';
import 'profile_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny), label: 'Oggi'),
    NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Itinerario'),
    NavigationDestination(icon: Icon(Icons.location_city_outlined), selectedIcon: Icon(Icons.location_city), label: 'Quartieri'),
    NavigationDestination(icon: Icon(Icons.near_me_outlined), selectedIcon: Icon(Icons.near_me), label: 'Vicino'),
    NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Cibo'),
    NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Tutto'),
  ];

  List<Widget> _pages() => [
        HomeScreen(onNavigate: (index) => setState(() => _index = index)),
        const ItineraryScreen(),
        const NeighborhoodsScreen(),
        const NearbyScreen(),
        const FoodScreen(),
        const AllPlacesScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final controller = TripScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 960;
    final pages = _pages();

    final content = IndexedStack(index: _index, children: pages);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: const Color(0xFFFFFCF7).withValues(alpha: .94),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [AppTheme.orange, AppTheme.amber],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text('B26', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Barcelona 2026', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(
                    controller.privateConfig?.accommodation.name ?? '8–11 ottobre · 6 amici',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: CircleAvatar(
                backgroundColor: AppTheme.blue,
                foregroundColor: Colors.white,
                child: Text(
                  (controller.currentUser?.name.isNotEmpty ?? false) ? controller.currentUser!.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (index) => setState(() => _index = index),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: const Color(0xFFFFFBF5),
                  destinations: _destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: _destinations,
            ),
    );
  }
}
