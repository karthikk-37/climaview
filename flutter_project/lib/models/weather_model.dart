/// Model representing current weather data from Open-Meteo Forecast API
class CurrentWeatherModel {
  final double temperature;
  final double apparentTemperature; // feels-like
  final int relativeHumidity;
  final double windSpeed;
  final int windDirection;
  final double surfacePressure;
  final int weatherCode;
  final String time;

  CurrentWeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.windDirection,
    required this.surfacePressure,
    required this.weatherCode,
    required this.time,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['wind_direction_10m'] as num?)?.toInt() ?? 0,
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble() ?? 1013.25,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      time: json['time'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature_2m': temperature,
      'apparent_temperature': apparentTemperature,
      'relative_humidity_2m': relativeHumidity,
      'wind_speed_10m': windSpeed,
      'wind_direction_10m': windDirection,
      'surface_pressure': surfacePressure,
      'weather_code': weatherCode,
      'time': time,
    };
  }
}
