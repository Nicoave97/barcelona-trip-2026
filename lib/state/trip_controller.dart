import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/backend_service.dart';

class TripController extends ChangeNotifier {
  TripController({BackendService? backend}) : _backend = backend ?? BackendService();

  static const _sessionKey = 'bcn_flutter_session_v1';
  static const _bootstrapCacheKey = 'bcn_flutter_bootstrap_v1';

  final BackendService _backend;

  bool initialized = false;
  bool loading = false;
  bool online = false;
  String? error;

  TripSession? session;
  PublicTripData? publicData;
  PrivateTripConfig? privateConfig;
  List<UserProfile> profiles = const [];
  List<ItineraryItem> itineraryItems = const [];
  final Map<String, EntityState> states = {};

  UserProfile? get currentUser => session?.user;
  bool get isLoggedIn => session != null;
  bool get isAdmin => session?.user.isAdmin ?? false;

  List<Place> get places {
    final data = publicData;
    if (data == null) return const [];
    final home = privateConfig?.accommodation;
    return data.places.map((p) {
      if (p.id == 'urbancomfort' && home != null) {
        return p.copyWith(
          name: home.name,
          lat: home.lat,
          lng: home.lng,
          why: home.address.isEmpty
              ? p.why
              : '${home.address}. ${home.metro}'.trim(),
        );
      }
      return p;
    }).toList();
  }

  Future<void> initialize() async {
    try {
      final raw = await rootBundle.loadString('assets/data/public_data.json');
      publicData = PublicTripData.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_sessionKey);
      if (saved != null) {
        try {
          final parsed = TripSession.fromJson(
            Map<String, dynamic>.from(jsonDecode(saved) as Map),
          );
          if (parsed.expiresAt.isAfter(DateTime.now())) {
            session = parsed;
            await bootstrap(allowCache: true);
          } else {
            await prefs.remove(_sessionKey);
          }
        } catch (_) {
          await prefs.remove(_sessionKey);
        }
      }
    } finally {
      initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String pin) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final newSession = await _backend.login(pin);
      session = newSession;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(newSession.toJson()));
      await bootstrap();
      return true;
    } on BackendException catch (e) {
      error = e.message;
      session = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      return false;
    } catch (_) {
      error = 'Connessione non disponibile. Riprova.';
      session = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> bootstrap({bool allowCache = false}) async {
    final token = session?.token;
    if (token == null) return;
    try {
      final payload = await _backend.api(token, 'bootstrap');
      _applyBootstrap(payload);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_bootstrapCacheKey, jsonEncode(payload));
      online = true;
      error = null;
    } on BackendException catch (e) {
      if (e.statusCode == 401) {
        await logout(localOnly: true);
        return;
      }
      if (!allowCache || !await _loadCachedBootstrap()) rethrow;
      online = false;
    } catch (_) {
      if (!allowCache || !await _loadCachedBootstrap()) rethrow;
      online = false;
    }
    notifyListeners();
  }

  Future<bool> _loadCachedBootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bootstrapCacheKey);
    if (raw == null) return false;
    try {
      _applyBootstrap(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      return true;
    } catch (_) {
      return false;
    }
  }

  void _applyBootstrap(Map<String, dynamic> payload) {
    if (payload['user'] is Map && session != null) {
      session = TripSession(
        token: session!.token,
        expiresAt: session!.expiresAt,
        user: UserProfile.fromJson(
          Map<String, dynamic>.from(payload['user'] as Map),
        ),
      );
    }

    profiles = (payload['profiles'] as List? ?? const [])
        .map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    states
      ..clear()
      ..addEntries(
        (payload['states'] as List? ?? const []).map((e) {
          final state = EntityState.fromJson(Map<String, dynamic>.from(e as Map));
          return MapEntry(state.compoundKey, state);
        }),
      );

    itineraryItems = (payload['tripItems'] as List? ?? const [])
        .map((e) => ItineraryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) {
        final day = a.dayKey.compareTo(b.dayKey);
        return day != 0 ? day : a.sortOrder.compareTo(b.sortOrder);
      });

    final settings = payload['settings'] as List? ?? const [];
    for (final raw in settings) {
      final row = Map<String, dynamic>.from(raw as Map);
      if (row['key'] == 'trip_private_config' && row['value'] is Map) {
        privateConfig = PrivateTripConfig.fromJson(
          Map<String, dynamic>.from(row['value'] as Map),
        );
      }
    }
  }

  EntityState? stateFor(String type, String key, {String? profileId}) {
    final id = profileId ?? currentUser?.id;
    if (id == null) return null;
    return states['$id:$type:$key'];
  }

  List<EntityState> groupStates(String type, String key) => states.values
      .where((s) => s.entityType == type && s.entityKey == key && s.completed)
      .toList();

  int completedCount(String type) {
    final id = currentUser?.id;
    if (id == null) return 0;
    return states.values
        .where((s) => s.profileId == id && s.entityType == type && s.completed)
        .length;
  }

  int favoriteCount() {
    final id = currentUser?.id;
    if (id == null) return 0;
    return states.values.where((s) => s.profileId == id && s.favorite).length;
  }

  Future<void> saveState({
    required String entityType,
    required String entityKey,
    required bool completed,
    int? rating,
    String? note,
    bool? favorite,
  }) async {
    final token = session?.token;
    final user = currentUser;
    if (token == null || user == null) return;
    final old = stateFor(entityType, entityKey);
    final payload = await _backend.api(token, 'save_state', {
      'entityType': entityType,
      'entityKey': entityKey,
      'completed': completed,
      'rating': rating,
      'note': note,
      'favorite': favorite ?? old?.favorite ?? false,
    });
    if (payload['state'] is Map) {
      final next = EntityState.fromJson(
        Map<String, dynamic>.from(payload['state'] as Map),
      );
      states[next.compoundKey] = next;
    }
    online = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String entityType, String entityKey) async {
    final old = stateFor(entityType, entityKey);
    await saveState(
      entityType: entityType,
      entityKey: entityKey,
      completed: old?.completed ?? false,
      rating: old?.rating,
      note: old?.note,
      favorite: !(old?.favorite ?? false),
    );
  }

  Future<void> deleteState(String entityType, String entityKey) async {
    final token = session?.token;
    final user = currentUser;
    if (token == null || user == null) return;
    await _backend.api(token, 'delete_state', {
      'entityType': entityType,
      'entityKey': entityKey,
    });
    states.remove('${user.id}:$entityType:$entityKey');
    notifyListeners();
  }

  Future<void> replaceItinerary(List<ItineraryItem> items) async {
    final token = session?.token;
    if (token == null || !isAdmin) return;
    await _backend.api(token, 'replace_itinerary', {
      'items': items.map((e) => e.toApiJson()).toList(),
    });
    await bootstrap();
  }

  List<ItineraryItem> itemsForDay(String day) => itineraryItems
      .where((item) => item.dayKey == day)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  Place? placeById(String? id) {
    if (id == null) return null;
    for (final p in places) {
      if (p.id == id) return p;
    }
    return null;
  }

  String profileName(String id) {
    if (currentUser?.id == id) return currentUser!.name;
    for (final p in profiles) {
      if (p.id == id) return p.name;
    }
    return 'Utente';
  }

  Future<void> logout({bool localOnly = false}) async {
    final oldSession = session;
    if (!localOnly && oldSession != null) {
      try {
        await _backend.api(oldSession.token, 'logout');
      } catch (_) {}
    }
    session = null;
    privateConfig = null;
    profiles = const [];
    itineraryItems = const [];
    states.clear();
    online = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }
}
