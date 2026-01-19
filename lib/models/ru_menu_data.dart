class RuMenuData {
  final Metadata metadata;
  final Map<String, Restaurant> restaurants;
  final Map<String, DayMenu> menus;

  RuMenuData({
    required this.metadata,
    required this.restaurants,
    required this.menus,
  });

  factory RuMenuData.fromJson(Map<String, dynamic> json) {
    final metadataJson =
        (json['metadata'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final restaurantsJson =
        (json['restaurants'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final menusJson =
        (json['menus'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    return RuMenuData(
      metadata: Metadata.fromJson(metadataJson),
      restaurants: restaurantsJson.map(
        (key, value) => MapEntry(key, Restaurant.fromJson(value)),
      ),
      menus: menusJson.map(
        (key, value) => MapEntry(key, DayMenu.fromJson(value)),
      ),
    );
  }
}

class Metadata {
  final String scrapedAt;
  final String sourceUrl;
  final String weekPeriod;

  Metadata({
    required this.scrapedAt,
    required this.sourceUrl,
    required this.weekPeriod,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      scrapedAt: _asString(json['scraped_at']),
      sourceUrl: _asString(json['source_url']),
      weekPeriod: _asString(json['week_period']),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String location;
  final Hours hours;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.hours,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final hoursJson =
        (json['hours'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    return Restaurant(
      id: _asString(json['id']),
      name: _asString(json['name']),
      location: _asString(json['location']),
      hours: Hours.fromJson(hoursJson),
    );
  }
}

class Hours {
  final String? lunch;
  final String? dinner;

  Hours({this.lunch, this.dinner});

  factory Hours.fromJson(Map<String, dynamic> json) {
    return Hours(
      lunch: _asNullableString(json['lunch']),
      dinner: _asNullableString(json['dinner']),
    );
  }
}

class DayMenu {
  final List<MenuOption> lunch;
  final List<MenuOption> dinner;

  DayMenu({required this.lunch, required this.dinner});

  factory DayMenu.fromJson(Map<String, dynamic> json) {
    final lunchList = (json['lunch'] as List?) ?? const [];
    final dinnerList = (json['dinner'] as List?) ?? const [];

    return DayMenu(
      lunch: lunchList
          .whereType<Map>()
          .map((i) => MenuOption.fromJson(i.cast<String, dynamic>()))
          .toList(),
      dinner: dinnerList
          .whereType<Map>()
          .map((i) => MenuOption.fromJson(i.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class MenuOption {
  final List<String> availableAt;
  final List<String> items;

  MenuOption({required this.availableAt, required this.items});

  factory MenuOption.fromJson(Map<String, dynamic> json) {
    final availableAtList = (json['available_at'] as List?) ?? const [];
    final itemsList = (json['items'] as List?) ?? const [];

    return MenuOption(
      availableAt: availableAtList
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList(),
      items: itemsList
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList(),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString();
  return parsed.isEmpty ? null : parsed;
}
