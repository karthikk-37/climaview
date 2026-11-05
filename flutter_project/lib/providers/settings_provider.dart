import 'package:flutter/foundation.dart';
import '../models/weather_settings_model.dart';
import '../services/storage_service.dart';

/// SettingsProvider manages units (Temp, Wind, Precipitation) and local persistence (GP1, GP6)
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  WeatherSettingsModel _settings = WeatherSettingsModel();
  WeatherSettingsModel get settings => _settings;

  TemperatureUnit get tempUnit => _settings.temperatureUnit;
  WindSpeedUnit get windUnit => _settings.windSpeedUnit;
  PrecipitationUnit get precipUnit => _settings.precipitationUnit;

  SettingsProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  Future<void> loadSettings() async {
    _settings = await _storageService.loadSettings();
    notifyListeners();
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    _settings = _settings.copyWith(temperatureUnit: unit);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setWindSpeedUnit(WindSpeedUnit unit) async {
    _settings = _settings.copyWith(windSpeedUnit: unit);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setPrecipitationUnit(PrecipitationUnit unit) async {
    _settings = _settings.copyWith(precipitationUnit: unit);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _settings = WeatherSettingsModel(
      temperatureUnit: TemperatureUnit.celsius,
      windSpeedUnit: WindSpeedUnit.kmh,
      precipitationUnit: PrecipitationUnit.mm,
    );
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  // --- Unit Conversion Helpers ---

  /// Format temperature according to selected unit
  String formatTemperature(double celsius, {bool showUnit = true}) {
    if (tempUnit == TemperatureUnit.fahrenheit) {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return '${fahrenheit.round()}${showUnit ? '°F' : '°'}';
    }
    return '${celsius.round()}${showUnit ? '°C' : '°'}';
  }

  /// Format wind speed according to selected unit
  String formatWindSpeed(double kmh) {
    if (windUnit == WindSpeedUnit.mph) {
      final mph = kmh * 0.621371;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  /// Format precipitation according to selected unit
  String formatPrecipitation(double mm) {
    if (precipUnit == PrecipitationUnit.inch) {
      final inches = mm * 0.0393701;
      return '${inches.toStringAsFixed(2)} in';
    }
    return '${mm.toStringAsFixed(1)} mm';
  }
}
