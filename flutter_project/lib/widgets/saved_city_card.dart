import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../providers/settings_provider.dart';
import '../utils/weather_code_helper.dart';

/// Card for saved cities screen with quick weather and delete confirmation (GP1, GP3)
class SavedCityCard extends StatelessWidget {
  final CityModel city;
  final CurrentWeatherModel? weather;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SavedCityCard({
    Key? key,
    required this.city,
    this.weather,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove City'),
        content: Text('Are you sure you want to remove ${city.name} from your saved cities?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final condition = weather != null ? WeatherCodeHelper.getInfo(weather!.weatherCode) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Weather icon or location pin
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (condition?.cardBackgroundColor ?? Colors.blue).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  condition?.icon ?? Icons.location_city_rounded,
                  color: condition?.cardBackgroundColor ?? Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // City & Country
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${city.admin1 != null ? "${city.admin1}, " : ""}${city.country}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Temperature badge if loaded
              if (weather != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      settings.formatTemperature(weather!.temperature),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      condition?.description ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                onPressed: () => _showDeleteDialog(context),
                tooltip: 'Remove City',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
