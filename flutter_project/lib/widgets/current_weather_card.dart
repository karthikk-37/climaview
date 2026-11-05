import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../providers/settings_provider.dart';
import '../utils/weather_code_helper.dart';

/// Hero Card rendering current temperature and atmospheric conditions with dynamic gradients
class CurrentWeatherCard extends StatelessWidget {
  final CityModel city;
  final CurrentWeatherModel weather;
  final double? maxTemp;
  final double? minTemp;

  const CurrentWeatherCard({
    Key? key,
    required this.city,
    required this.weather,
    this.maxTemp,
    this.minTemp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeHelper.getInfo(weather.weatherCode);
    final settings = Provider.of<SettingsProvider>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: condition.gradientColors,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: condition.gradientColors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  city.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            city.country,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Icon(
            condition.icon,
            size: 72,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            settings.formatTemperature(weather.temperature),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 68,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            condition.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Feels like ${settings.formatTemperature(weather.apparentTemperature)}'
            '${maxTemp != null && minTemp != null ? "  •  H: ${settings.formatTemperature(maxTemp!)} L: ${settings.formatTemperature(minTemp!)}" : ""}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
