enum TemperatureUnit {
  celsius,
  fahrenheit,
}

enum WindSpeedUnit {
  kmh,
  mph,
}

enum PrecipitationUnit {
  mm,
  inch,
}

class WeatherSettingsModel {
  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;
  final PrecipitationUnit precipitationUnit;

  WeatherSettingsModel({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windSpeedUnit = WindSpeedUnit.kmh,
    this.precipitationUnit = PrecipitationUnit.mm,
  });

  WeatherSettingsModel copyWith({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
    PrecipitationUnit? precipitationUnit,
  }) {
    return WeatherSettingsModel(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
      precipitationUnit: precipitationUnit ?? this.precipitationUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatureUnit': temperatureUnit.name,
      'windSpeedUnit': windSpeedUnit.name,
      'precipitationUnit': precipitationUnit.name,
    };
  }

  factory WeatherSettingsModel.fromJson(Map<String, dynamic> json) {
    return WeatherSettingsModel(
      temperatureUnit: json['temperatureUnit'] == 'fahrenheit'
          ? TemperatureUnit.fahrenheit
          : TemperatureUnit.celsius,
      windSpeedUnit: json['windSpeedUnit'] == 'mph'
          ? WindSpeedUnit.mph
          : WindSpeedUnit.kmh,
      precipitationUnit: json['precipitationUnit'] == 'inch'
          ? PrecipitationUnit.inch
          : PrecipitationUnit.mm,
    );
  }
}
