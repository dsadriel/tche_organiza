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
    return RuMenuData(
      metadata: Metadata.fromJson(json['metadata']),
      restaurants: (json['restaurants'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Restaurant.fromJson(value)),
      ),
      menus: (json['menus'] as Map<String, dynamic>).map(
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
      scrapedAt: json['scraped_at'],
      sourceUrl: json['source_url'],
      weekPeriod: json['week_period'],
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
    return Restaurant(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      hours: Hours.fromJson(json['hours']),
    );
  }
}

class Hours {
  final String? lunch;
  final String? dinner;

  Hours({this.lunch, this.dinner});

  factory Hours.fromJson(Map<String, dynamic> json) {
    return Hours(
      lunch: json['lunch'],
      dinner: json['dinner'],
    );
  }
}

class DayMenu {
  final List<MenuOption> lunch;
  final List<MenuOption> dinner;

  DayMenu({
    required this.lunch,
    required this.dinner,
  });

  factory DayMenu.fromJson(Map<String, dynamic> json) {
    return DayMenu(
      lunch: (json['lunch'] as List? ?? [])
          .map((i) => MenuOption.fromJson(i))
          .toList(),
      dinner: (json['dinner'] as List? ?? [])
          .map((i) => MenuOption.fromJson(i))
          .toList(),
    );
  }
}

class MenuOption {
  final List<String> availableAt;
  final List<String> items;

  MenuOption({
    required this.availableAt,
    required this.items,
  });

  factory MenuOption.fromJson(Map<String, dynamic> json) {
    return MenuOption(
      availableAt: List<String>.from(json['available_at']),
      items: List<String>.from(json['items']),
    );
  }
}