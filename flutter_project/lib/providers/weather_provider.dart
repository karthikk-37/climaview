import 'package:flutter/foundation.dart';
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_api_service.dart';
import '../services/storage_service.dart';

enum WeatherStatus { initial, loading, success, error }

/// WeatherProvider manages current city weather, forecast and search state (GP6)
class WeatherProvider extends ChangeNotifier {
  final WeatherApiService _apiService;
  final StorageService _storageService;

  WeatherStatus _status = WeatherStatus.initial;
  WeatherStatus get status => _status;

  CityModel? _currentCity;
  CityModel? get currentCity => _currentCity;

  CurrentWeatherModel? _currentWeather;
  CurrentWeatherModel? get currentWeather => _currentWeather;

  List<DailyForecastModel> _forecast = [];
  List<DailyForecastModel> get forecast => _forecast;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<CityModel> _searchResults = [];
  List<CityModel> get searchResults => _searchResults;

  String? _searchError;
  String? get searchError => _searchError;

  WeatherProvider({
    WeatherApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? StorageService();

  /// Initialize default or last-viewed city
  Future<void> initializeDefaultCity() async {
    final lastCity = await _storageService.loadLastCity();
    if (lastCity != null) {
      await fetchWeatherForCity(lastCity);
    } else {
      // Default initial city: London
      final defaultCity = CityModel(
        id: 2643743,
        name: 'London',
        latitude: 51.50853,
        longitude: -0.12574,
        country: 'United Kingdom',
        admin1: 'England',
      );
      await fetchWeatherForCity(defaultCity);
    }
  }

  /// Fetch weather for a given city
  Future<void> fetchWeatherForCity(CityModel city) async {
    _status = WeatherStatus.loading;
    _errorMessage = null;
    _currentCity = city;
    notifyListeners();

    try {
      final data = await _apiService.fetchWeatherAndForecast(
        latitude: city.latitude,
        longitude: city.longitude,
      );

      _currentWeather = data['current'] as CurrentWeatherModel;
      _forecast = data['forecast'] as List<DailyForecastModel>;
      _status = WeatherStatus.success;
      await _storageService.saveLastCity(city);
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Refresh weather data for currently selected city
  Future<void> refreshCurrentCity() async {
    if (_currentCity != null) {
      await fetchWeatherForCity(_currentCity!);
    }
  }

  /// Search for cities using Geocoding API with form validation (GP4)
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _searchError = 'Please enter a city name to search.';
      notifyListeners();
      return;
    }

    if (trimmed.length > 60) {
      _searchResults = [];
      _searchError = 'City name is too long. Please shorten your query.';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final results = await _apiService.searchCities(trimmed);
      _searchResults = results;
      if (results.isEmpty) {
        _searchError = 'No matching cities found for "$trimmed".';
      }
    } catch (e) {
      _searchResults = [];
      _searchError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search bar results
  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    _isSearching = false;
    notifyListeners();
  }
}
