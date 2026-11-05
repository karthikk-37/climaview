import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/forecast_model.dart';
import '../providers/settings_provider.dart';
import '../utils/weather_code_helper.dart';

/// Card rendering single forecast day in 7-day multi-day list (GP1, GP5)
class ForecastCard extends StatelessWidget {
  final DailyForecastModel forecast;
  final bool isToday;

  const ForecastCard({
    Key? key,
    required this.forecast,
    this.isToday = false,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      if (isToday) return 'Today';
      return DateFormat('EEE, MMM d').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeHelper.getInfo(forecast.weatherCode);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Date & Day
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(forecast.date),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: isToday ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
                Text(
                  condition.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Weather Icon
          Icon(
            condition.icon,
            size: 26,
            color: condition.cardBackgroundColor,
          ),
          const SizedBox(width: 12),
          // Rain probability if available
          Expanded(
            child: Row(
              children: [
                if (forecast.precipitationProbability > 0) ...[
                  const Icon(Icons.water_drop, size: 14, color: Colors.blueAccent),
                  const SizedBox(width: 3),
                  Text(
                    '${forecast.precipitationProbability}%',
                    style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                  ),
                ] else
                  const Text('·', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          // High / Low temperatures
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                settings.formatTemperature(forecast.maxTemperature),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                settings.formatTemperature(forecast.minTemperature),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
