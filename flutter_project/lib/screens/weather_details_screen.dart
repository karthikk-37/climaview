import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../providers/weather_provider.dart';
import '../widgets/forecast_card.dart';

/// Screen 2: Detailed 7-Day Weather Forecast Screen (GP1, GP5)
class WeatherDetailsScreen extends StatelessWidget {
  final CityModel city;

  const WeatherDetailsScreen({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${city.name} Forecast',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '7-Day Meteorological Outlook',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          final forecast = weatherProvider.forecast;

          if (weatherProvider.status == WeatherStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (forecast.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No forecast records available.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => weatherProvider.refreshCurrentCity(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: forecast.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return ForecastCard(
                forecast: forecast[index],
                isToday: index == 0,
              );
            },
          );
        },
      ),
    );
  }
}
