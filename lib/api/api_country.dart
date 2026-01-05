// api_country.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:timeless/api/model/api_country_model.dart';

// Handles country, state, and city data fetched from an external source
// Mainly used to populate location selectors across the application
class CountrySearch {
  static get HttpService => null;

  // Fetches the full list of countries with their states and cities
  // Data is retrieved from a public JSON file hosted on GitHub
  static Future<List<SearchCountry>?> countNotification() async {
    var url =
        "https://raw.githubusercontent.com/prof22/country_state_city_picker/main/lib/assets/country.json";

    http.Response? response = await HttpService.getApi(url: url);

    if (response!.statusCode == 200) {
      return searchCountryFromJson(response.body);
    } else {
      // Logs the error response only in debug mode
      // This avoids exposing technical details in production
      if (kDebugMode) {
        print(jsonDecode(response.body));
      }
    }
    return null;
  }
}
