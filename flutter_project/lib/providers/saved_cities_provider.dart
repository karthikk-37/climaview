import 'package:flutter/foundation.dart';
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_api_service.dart';

enum SavedCitiesStatus { initial, loading, success, error }

/// SavedCitiesProvider manages bookmarked cities with duplicate check and persistence (GP1, GP3, GP6)
class SavedCitiesProvider extends ChangeNotifier {
  final StorageService _storageService;
  final WeatherApiService _apiService;

  SavedCitiesStatus _status = SavedCitiesStatus.initial;
  SavedCitiesStatus get status => _status;

  List<CityModel> _savedCities = [];
  List<CityModel> get savedCities => _savedCities;

  final Map<int, CurrentWeatherModel> _cityWeatherCache = {};
  Map<int, CurrentWeatherModel> get cityWeatherCache => _cityWeatherCache;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SavedCitiesProvider({
    StorageService? storageService,
    WeatherApiService? apiService,
  })  : _storageService = storageService ?? StorageService(),
        _apiService = apiService ?? WeatherApiService();

  /// Load cities from storage and fetch current quick-weather
  Future<void> loadSavedCities() async {
    _status = SavedCitiesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _savedCities = await _storageService.loadSavedCities();
      _status = SavedCitiesStatus.success;
      notifyListeners();

      // Refresh quick weather for each saved city
      for (final city in _savedCities) {
        _fetchCityQuickWeather(city);
      }
    } catch (e) {
      _status = SavedCitiesStatus.error;
      _errorMessage = 'Failed to load saved cities: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchCityQuickWeather(CityModel city) async {
    try {
      final data = await _apiService.fetchWeatherAndForecast(
        latitude: city.latitude,
        longitude: city.longitude,
      );
      _cityWeatherCache[city.id] = data['current'] as CurrentWeatherModel;
      notifyListeners();
    } catch (_) {
      // Keep previous cached value if network fails for one city
    }
  }

  /// Add city with duplicate prevention
  Future<bool> addCity(CityModel city) async {
    final alreadyExists = _savedCities.any((c) => c.id == city.id || (c.name.toLowerCase() == city.name.toLowerCase() && c.country == city.country));
    if (alreadyExists) {
      return false; // Prevent duplicates
    }

    _savedCities.add(city);
    await _storageService.saveCities(_savedCities);
    _fetchCityQuickWeather(city);
    notifyListeners();
    return true;
  }

  /// Remove city by ID
  Future<void> removeCity(int cityId) async {
    _savedCities.removeWhere((c) => c.id == cityId);
    _cityWeatherCache.remove(cityId);
    await _storageService.saveCities(_savedCities);
    notifyListeners();
  }

  /// Check if a city is already bookmarked
  bool isCitySaved(int cityId) {
    return _savedCities.any((c) => c.id == cityId);
  }
}
