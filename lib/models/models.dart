class UserProfile {
  const UserProfile({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final String role;

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? json['display_name'] ?? '').toString(),
        role: (json['role'] ?? 'user').toString(),
      );
}

class TripSession {
  const TripSession({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  final String token;
  final DateTime expiresAt;
  final UserProfile user;

  Map<String, dynamic> toJson() => {
        'token': token,
        'expiresAt': expiresAt.toIso8601String(),
        'user': {'id': user.id, 'name': user.name, 'role': user.role},
      };

  factory TripSession.fromJson(Map<String, dynamic> json) => TripSession(
        token: json['token'].toString(),
        expiresAt: DateTime.parse(json['expiresAt'].toString()),
        user: UserProfile.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      );
}

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.price,
    required this.duration,
    required this.level,
    required this.budget,
    required this.why,
    this.lat,
    this.lng,
    this.details,
    this.highlights = const [],
    this.tips,
  });

  final String id;
  final String name;
  final String type;
  final String area;
  final String price;
  final String duration;
  final String level;
  final String budget;
  final double? lat;
  final double? lng;
  final String why;
  final String? details;
  final List<String> highlights;
  final String? tips;

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: json['id'].toString(),
        name: json['name'].toString(),
        type: (json['type'] ?? '').toString(),
        area: (json['area'] ?? '').toString(),
        price: (json['price'] ?? '').toString(),
        duration: (json['duration'] ?? '').toString(),
        level: (json['level'] ?? '').toString(),
        budget: (json['budget'] ?? '').toString(),
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        why: (json['why'] ?? '').toString(),
        details: json['details']?.toString(),
        highlights: (json['highlights'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        tips: json['tips']?.toString(),
      );

  Place copyWith({double? lat, double? lng, String? name, String? why}) => Place(
        id: id,
        name: name ?? this.name,
        type: type,
        area: area,
        price: price,
        duration: duration,
        level: level,
        budget: budget,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        why: why ?? this.why,
        details: details,
        highlights: highlights,
        tips: tips,
      );
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.kind,
    required this.description,
  });
  final String id;
  final String name;
  final String price;
  final String kind;
  final String description;

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'].toString(),
        name: json['name'].toString(),
        price: (json['price'] ?? '').toString(),
        kind: (json['kind'] ?? '').toString(),
        description: (json['desc'] ?? '').toString(),
      );
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.spend,
    required this.level,
    required this.dishes,
    required this.note,
    this.lat,
    this.lng,
  });
  final String id;
  final String name;
  final String area;
  final String address;
  final String spend;
  final String level;
  final List<String> dishes;
  final String note;
  final double? lat;
  final double? lng;

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'].toString(),
        name: json['name'].toString(),
        area: (json['area'] ?? '').toString(),
        address: (json['address'] ?? '').toString(),
        spend: (json['spend'] ?? '').toString(),
        level: (json['level'] ?? '').toString(),
        dishes: (json['dishes'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        note: (json['note'] ?? '').toString(),
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class Neighborhood {
  const Neighborhood({
    required this.id,
    required this.name,
    required this.icon,
    required this.distance,
    required this.description,
    required this.placeIds,
  });
  final String id;
  final String name;
  final String icon;
  final String distance;
  final String description;
  final List<String> placeIds;

  factory Neighborhood.fromJson(Map<String, dynamic> json) => Neighborhood(
        id: json['id'].toString(),
        name: json['name'].toString(),
        icon: (json['icon'] ?? '📍').toString(),
        distance: (json['distance'] ?? '').toString(),
        description: (json['desc'] ?? '').toString(),
        placeIds: (json['placeIds'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

class ItineraryDayMeta {
  const ItineraryDayMeta({
    required this.day,
    required this.title,
    required this.tag,
    required this.note,
  });
  final String day;
  final String title;
  final String tag;
  final String note;

  factory ItineraryDayMeta.fromJson(Map<String, dynamic> json) => ItineraryDayMeta(
        day: json['day'].toString(),
        title: (json['title'] ?? '').toString(),
        tag: (json['tag'] ?? '').toString(),
        note: (json['note'] ?? '').toString(),
      );
}

class ItineraryItem {
  const ItineraryItem({
    required this.id,
    required this.dayKey,
    required this.sortOrder,
    required this.title,
    this.timeLabel,
    this.kind,
    this.placeId,
    this.travel,
    this.travelTime,
    this.travelTip,
    this.optionalNote,
  });

  final String id;
  final String dayKey;
  final int sortOrder;
  final String? timeLabel;
  final String title;
  final String? kind;
  final String? placeId;
  final String? travel;
  final String? travelTime;
  final String? travelTip;
  final String? optionalNote;

  factory ItineraryItem.fromJson(Map<String, dynamic> json) => ItineraryItem(
        id: (json['id'] ?? '').toString(),
        dayKey: (json['day_key'] ?? '').toString(),
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        timeLabel: json['time_label']?.toString(),
        title: (json['title'] ?? '').toString(),
        kind: json['kind']?.toString(),
        placeId: json['place_id']?.toString(),
        travel: json['travel']?.toString(),
        travelTime: json['travel_time']?.toString(),
        travelTip: json['travel_tip']?.toString(),
        optionalNote: json['optional_note']?.toString(),
      );

  static const _notProvided = Object();

  ItineraryItem copyWith({
    String? id,
    String? dayKey,
    int? sortOrder,
    String? timeLabel,
    String? title,
    String? kind,
    Object? placeId = _notProvided,
    String? travel,
    String? travelTime,
    String? travelTip,
    String? optionalNote,
  }) =>
      ItineraryItem(
        id: id ?? this.id,
        dayKey: dayKey ?? this.dayKey,
        sortOrder: sortOrder ?? this.sortOrder,
        timeLabel: timeLabel ?? this.timeLabel,
        title: title ?? this.title,
        kind: kind ?? this.kind,
        placeId: identical(placeId, _notProvided) ? this.placeId : placeId as String?,
        travel: travel ?? this.travel,
        travelTime: travelTime ?? this.travelTime,
        travelTip: travelTip ?? this.travelTip,
        optionalNote: optionalNote ?? this.optionalNote,
      );

  Map<String, dynamic> toApiJson() => {
        'day_key': dayKey,
        'sort_order': sortOrder,
        'time_label': timeLabel,
        'title': title,
        'kind': kind,
        'place_id': placeId,
        'travel': travel,
        'travel_time': travelTime,
        'travel_tip': travelTip,
        'optional_note': optionalNote,
      };
}

class EntityState {
  const EntityState({
    required this.profileId,
    required this.entityType,
    required this.entityKey,
    required this.completed,
    required this.favorite,
    this.rating,
    this.note,
    this.updatedAt,
  });
  final String profileId;
  final String entityType;
  final String entityKey;
  final bool completed;
  final bool favorite;
  final int? rating;
  final String? note;
  final DateTime? updatedAt;

  String get compoundKey => '$profileId:$entityType:$entityKey';

  factory EntityState.fromJson(Map<String, dynamic> json) => EntityState(
        profileId: (json['profile_id'] ?? '').toString(),
        entityType: (json['entity_type'] ?? '').toString(),
        entityKey: (json['entity_key'] ?? '').toString(),
        completed: json['completed'] == true,
        favorite: json['favorite'] == true,
        rating: (json['rating'] as num?)?.toInt(),
        note: json['note']?.toString(),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.tryParse(json['updated_at'].toString()),
      );
}

class AccommodationConfig {
  const AccommodationConfig({
    required this.name,
    required this.address,
    required this.metro,
    this.lat,
    this.lng,
  });
  final String name;
  final String address;
  final String metro;
  final double? lat;
  final double? lng;

  factory AccommodationConfig.fromJson(Map<String, dynamic> json) =>
      AccommodationConfig(
        name: (json['name'] ?? 'Alloggio del gruppo').toString(),
        address: (json['address'] ?? '').toString(),
        metro: (json['metro'] ?? '').toString(),
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class AirportConfig {
  const AirportConfig({required this.out, required this.t2, required this.back});
  final String out;
  final String t2;
  final String back;

  factory AirportConfig.fromJson(Map<String, dynamic> json) => AirportConfig(
        out: (json['out'] ?? '').toString(),
        t2: (json['t2'] ?? '').toString(),
        back: (json['back'] ?? '').toString(),
      );
}

class PrivateTripConfig {
  const PrivateTripConfig({required this.accommodation, required this.airport});
  final AccommodationConfig accommodation;
  final AirportConfig airport;

  factory PrivateTripConfig.fromJson(Map<String, dynamic> json) => PrivateTripConfig(
        accommodation: AccommodationConfig.fromJson(
          Map<String, dynamic>.from(json['accommodation'] as Map? ?? const {}),
        ),
        airport: AirportConfig.fromJson(
          Map<String, dynamic>.from(json['airport'] as Map? ?? const {}),
        ),
      );
}

class PublicTripData {
  const PublicTripData({
    required this.title,
    required this.dates,
    required this.neighborhoods,
    required this.dayMeta,
    required this.places,
    required this.foods,
    required this.restaurants,
  });
  final String title;
  final String dates;
  final List<Neighborhood> neighborhoods;
  final List<ItineraryDayMeta> dayMeta;
  final List<Place> places;
  final List<FoodItem> foods;
  final List<Restaurant> restaurants;

  factory PublicTripData.fromJson(Map<String, dynamic> json) {
    final trip = Map<String, dynamic>.from(json['trip'] as Map);
    return PublicTripData(
      title: (trip['title'] ?? 'Barcelona 2026').toString(),
      dates: (trip['dates'] ?? '').toString(),
      neighborhoods: (trip['neighborhoods'] as List)
          .map((e) => Neighborhood.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      dayMeta: (trip['itinerary'] as List)
          .map((e) => ItineraryDayMeta.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      places: (json['places'] as List)
          .map((e) => Place.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      foods: (json['foods'] as List)
          .map((e) => FoodItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      restaurants: (json['restaurants'] as List)
          .map((e) => Restaurant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
