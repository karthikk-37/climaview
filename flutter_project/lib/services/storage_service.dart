import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city_model.dart';
import '../models/weather_settings_model.dart';

/// Service managing persistent on-device storage using SharedPreferences (GP1, GP8)
class StorageService {
  static const String _keySavedCities = 'climaview_saved_cities';
  static const String _keySettings = 'climaview_settings';
  static const String _keyLastCity = 'climaview_last_selected_city';

  /// Load all saved cities from SharedPreferences
  Future<List<CityModel>> loadSavedCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_keySavedCities);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> list = json.decode(jsonString);
      return list.map((item) => CityModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // In case of corrupt local storage data, fail safely
      return [];
    }
  }

  /// Save list of cities to SharedPreferences
  Future<bool> saveCities(List<CityModel> cities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(cities.map((c) => c.toJson()).toList());
      return await prefs.setString(_keySavedCities, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Load user unit settings
  Future<WeatherSettingsModel> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_keySettings);
      if (jsonString == null) {
        return WeatherSettingsModel();
      }
      return WeatherSettingsModel.fromJson(json.decode(jsonString));
    } catch (e) {
      return WeatherSettingsModel();
    }
  }

  /// Save user unit settings
  Future<bool> saveSettings(WeatherSettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keySettings, json.encode(settings.toJson()));
    } catch (e) {
      return false;
    }
  }

  /// Save last active city so app opens directly to user's location
  Future<void> saveLastCity(CityModel city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastCity, json.encode(city.toJson()));
    } catch (_) {}
  }

  /// Load last active city if present
  Future<CityModel?> loadLastCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyLastCity);
      if (jsonStr != null) {
        return CityModel.fromJson(json.decode(jsonStr));
      }
    } catch (_) {}
    return null;
  }
}
