import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

/// Service dedicated to making resilient HTTP calls to Open-Meteo APIs (GP2, GP8)
class WeatherApiService {
  static const String _geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Search cities by user input with error handling (GP4, GP8)
  Future<List<CityModel>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$_geoBaseUrl?name=${Uri.encodeComponent(cleanQuery)}&count=6&language=en&format=json');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] is List) {
          final List<dynamic> results = data['results'];
          return results.map((item) => CityModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      } else {
        throw Exception('Geocoding server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please verify your network.');
    } on TimeoutException {
      throw Exception('Search request timed out. Please try again.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error searching for city: $e');
    }
  }

  /// Fetch current weather and 7-day daily forecast for coordinates (GP2)
  Future<Map<String, dynamic>> fetchWeatherAndForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_weatherBaseUrl?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max'
      '&timezone=auto',
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final currentWeather = CurrentWeatherModel.fromJson(data['current'] as Map<String, dynamic>);
        final forecastList = DailyForecastModel.parseDailyForecastList(data['daily'] as Map<String, dynamic>);

        return {
          'current': currentWeather,
          'forecast': forecastList,
        };
      } else {
        throw Exception('Weather server error (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection. Please connect to Wi-Fi or Mobile Data.');
    } on TimeoutException {
      throw Exception('Weather request timed out. Open-Meteo servers took too long to reply.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to load weather: $e');
    }
  }
}
