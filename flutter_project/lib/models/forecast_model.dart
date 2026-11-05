/// Model representing single day forecast from Open-Meteo API
class DailyForecastModel {
  final String date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final int precipitationProbability;
  final double maxWindSpeed;

  DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbability,
    required this.maxWindSpeed,
  });

  factory DailyForecastModel.fromDailyJson({
    required String date,
    required int weatherCode,
    required double maxTemp,
    required double minTemp,
    required int precipProb,
    required double maxWind,
  }) {
    return DailyForecastModel(
      date: date,
      weatherCode: weatherCode,
      maxTemperature: maxTemp,
      minTemperature: minTemp,
      precipitationProbability: precipProb,
      maxWindSpeed: maxWind,
    );
  }

  static List<DailyForecastModel> parseDailyForecastList(Map<String, dynamic> dailyJson) {
    final List<dynamic> dates = dailyJson['time'] as List<dynamic>? ?? [];
    final List<dynamic> weatherCodes = dailyJson['weather_code'] as List<dynamic>? ?? [];
    final List<dynamic> maxTemps = dailyJson['temperature_2m_max'] as List<dynamic>? ?? [];
    final List<dynamic> minTemps = dailyJson['temperature_2m_min'] as List<dynamic>? ?? [];
    final List<dynamic> precipProbs = dailyJson['precipitation_probability_max'] as List<dynamic>? ?? [];
    final List<dynamic> maxWinds = dailyJson['wind_speed_10m_max'] as List<dynamic>? ?? [];

    final List<DailyForecastModel> list = [];
    final count = dates.length;

    for (int i = 0; i < count; i++) {
      list.add(
        DailyForecastModel(
          date: dates[i].toString(),
          weatherCode: i < weatherCodes.length ? (weatherCodes[i] as num).toInt() : 0,
          maxTemperature: i < maxTemps.length ? (maxTemps[i] as num).toDouble() : 0.0,
          minTemperature: i < minTemps.length ? (minTemps[i] as num).toDouble() : 0.0,
          precipitationProbability: i < precipProbs.length ? (precipProbs[i] as num).toInt() : 0,
          maxWindSpeed: i < maxWinds.length ? (maxWinds[i] as num).toDouble() : 0.0,
        ),
      );
    }
    return list;
  }
}
