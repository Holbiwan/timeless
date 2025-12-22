// Country search model for location picker
// Handles the hierarchical structure: Country > State > City

import 'dart:convert';

// Helper functions to parse JSON data from API
List<SearchCountry> searchCountryFromJson(String str) =>
    List<SearchCountry>.from(
        json.decode(str).map((x) => SearchCountry.fromJson(x)));

String searchCountryToJson(List<SearchCountry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchCountry {
  SearchCountry({
    this.id,
    this.name,
    this.emoji,
    this.emojiU,
    this.state,
  });

  int? id;
  String? name; // "France", "Canada", etc.
  String? emoji; // 🇫🇷, 🇨🇦
  String? emojiU; // Unicode version of flag
  List<State>? state; // All states/regions in this country

  factory SearchCountry.fromJson(Map<String, dynamic> json) => SearchCountry(
        id: json["id"],
        name: json["name"],
        emoji: json["emoji"],
        emojiU: json["emojiU"],
        state: List<State>.from(json["state"].map((x) => State.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "emoji": emoji,
        "emojiU": emojiU,
        "state": List<dynamic>.from(state!.map((x) => x.toJson())),
      };
}

class State {
  State({
    this.id,
    this.name,
    this.countryId,
    this.city,
  });

  int? id;
  String? name; // "Île-de-France", "California", "Ontario"
  int? countryId; // Points back to parent country
  List<City>? city; // All cities in this state

  factory State.fromJson(Map<String, dynamic> json) => State(
        id: json["id"],
        name: json["name"],
        countryId: json["country_id"],
        city: List<City>.from(json["city"].map((x) => City.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country_id": countryId,
        "city": List<dynamic>.from(city!.map((x) => x.toJson())),
      };
}

class City {
  City({
    this.id,
    this.name,
    this.stateId,
  });

  int? id;
  String? name; // "Paris", "Los Angeles", "Toronto"
  int? stateId; // Points back to parent state

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        name: json["name"],
        stateId: json["state_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "state_id": stateId,
      };
}
