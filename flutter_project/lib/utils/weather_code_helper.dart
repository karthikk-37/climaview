import 'package:flutter/material.dart';

class WeatherConditionInfo {
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color cardBackgroundColor;

  const WeatherConditionInfo({
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.cardBackgroundColor,
  });
}

/// Helper mapping Open-Meteo WMO weather codes to human descriptions, icons, and dynamic gradients
class WeatherCodeHelper {
  static WeatherConditionInfo getInfo(int code, {bool isNight = false}) {
    if (isNight) {
      return WeatherConditionInfo(
        description: _getDescription(code),
        icon: _getNightIcon(code),
        gradientColors: const [Color(0xFF0F172A), Color(0xFF1E293B)],
        cardBackgroundColor: const Color(0xFF1E293B),
      );
    }

    switch (code) {
      case 0:
        return const WeatherConditionInfo(
          description: 'Clear Sky',
          icon: Icons.wb_sunny_rounded,
          gradientColors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
          cardBackgroundColor: Color(0xFF2196F3),
        );
      case 1:
        return const WeatherConditionInfo(
          description: 'Mainly Clear',
          icon: Icons.wb_sunny_rounded,
          gradientColors: [Color(0xFF1E88E5), Color(0xFF90CAF9)],
          cardBackgroundColor: Color(0xFF2196F3),
        );
      case 2:
        return const WeatherConditionInfo(
          description: 'Partly Cloudy',
          icon: Icons.cloud_queue_rounded,
          gradientColors: [Color(0xFF455A64), Color(0xFF78909C)],
          cardBackgroundColor: Color(0xFF546E7A),
        );
      case 3:
        return const WeatherConditionInfo(
          description: 'Overcast',
          icon: Icons.cloud_rounded,
          gradientColors: [Color(0xFF37474F), Color(0xFF607D8B)],
          cardBackgroundColor: Color(0xFF455A64),
        );
      case 45:
      case 48:
        return const WeatherConditionInfo(
          description: 'Foggy',
          icon: Icons.foggy,
          gradientColors: [Color(0xFF455A64), Color(0xFF90A4AE)],
          cardBackgroundColor: Color(0xFF607D8B),
        );
      case 51:
      case 53:
      case 55:
        return const WeatherConditionInfo(
          description: 'Drizzle',
          icon: Icons.water_drop_outlined,
          gradientColors: [Color(0xFF283593), Color(0xFF5C6BC0)],
          cardBackgroundColor: Color(0xFF3949AB),
        );
      case 61:
      case 63:
      case 65:
        return const WeatherConditionInfo(
          description: 'Rain',
          icon: Icons.grain_rounded,
          gradientColors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
          cardBackgroundColor: Color(0xFF283593),
        );
      case 71:
      case 73:
      case 75:
        return const WeatherConditionInfo(
          description: 'Snow Fall',
          icon: Icons.ac_unit_rounded,
          gradientColors: [Color(0xFF546E7A), Color(0xFFB0BEC5)],
          cardBackgroundColor: Color(0xFF78909C),
        );
      case 80:
      case 81:
      case 82:
        return const WeatherConditionInfo(
          description: 'Rain Showers',
          icon: Icons.umbrella_rounded,
          gradientColors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          cardBackgroundColor: Color(0xFF1E88E5),
        );
      case 95:
      case 96:
      case 99:
        return const WeatherConditionInfo(
          description: 'Thunderstorm',
          icon: Icons.thunderstorm_rounded,
          gradientColors: [Color(0xFF311B92), Color(0xFF512DA8)],
          cardBackgroundColor: Color(0xFF4527A0),
        );
      default:
        return const WeatherConditionInfo(
          description: 'Cloudy',
          icon: Icons.cloud_rounded,
          gradientColors: [Color(0xFF37474F), Color(0xFF78909C)],
          cardBackgroundColor: Color(0xFF455A64),
        );
    }
  }

  static String _getDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Cloudy';
    }
  }

  static IconData _getNightIcon(int code) {
    if (code == 0 || code == 1) {
      return Icons.nightlight_round;
    }
    if (code >= 61 && code <= 65) {
      return Icons.grain_rounded;
    }
    if (code >= 95) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.cloud_rounded;
  }
}
