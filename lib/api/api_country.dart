import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:timeless/api/model/api_country_model.dart';
import 'package:timeless/services/http_service.dart';

// API service to fetch country/state/city data
class CountrySearch {
  // Gets all countries with their states and cities from GitHub repo
  // This is used for location pickers throughout the app
  static Future<List<SearchCountry>?> countNotification() async {
    var url =
        "https://raw.githubusercontent.com/prof22/country_state_city_picker/main/lib/assets/country.json";
    
    http.Response? response = await HttpService.getApi(url: url);
    
    if (response!.statusCode == 200) {
      return searchCountryFromJson(response.body);
    } else {
      // Log error in debug mode only
      if (kDebugMode) {
        print(jsonDecode(response.body));
      }
    }
    return null;
  }
}

