import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/saved_cities_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/weather_detail_card.dart';
import '../widgets/city_search_modal.dart';
import 'weather_details_screen.dart';
import 'saved_cities_screen.dart';
import 'settings_screen.dart';

/// Screen 1: ClimaView Main Weather Dashboard (GP1, GP3)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _openSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CitySearchModal(
        onCitySelected: (city) {
          Provider.of<WeatherProvider>(context, listen: false).fetchWeatherForCity(city);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'ClimaView',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search City',
            onPressed: () => _openSearchModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: 'Saved Cities',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedCitiesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          // Loading state (GP3)
          if (weatherProvider.status == WeatherStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching latest meteorological data...'),
                ],
              ),
            );
          }

          // Error state with retry (GP3, GP8)
          if (weatherProvider.status == WeatherStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Weather Data Unavailable',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weatherProvider.errorMessage ?? 'An unexpected network error occurred.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => weatherProvider.refreshCurrentCity(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty state before selection
          if (weatherProvider.currentCity == null || weatherProvider.currentWeather == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.travel_explore_rounded, size: 64, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  const Text('No city selected yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _openSearchModal(context),
                    child: const Text('Search for a City'),
                  ),
                ],
              ),
            );
          }

          final city = weatherProvider.currentCity!;
          final weather = weatherProvider.currentWeather!;
          final forecast = weatherProvider.forecast;
          final todayForecast = forecast.isNotEmpty ? forecast.first : null;
          final settings = Provider.of<SettingsProvider>(context);
          final savedCitiesProvider = Provider.of<SavedCitiesProvider>(context);
          final isSaved = savedCitiesProvider.isCitySaved(city.id);

          return RefreshIndicator(
            onRefresh: () => weatherProvider.refreshCurrentCity(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Weather Card
                  CurrentWeatherCard(
                    city: city,
                    weather: weather,
                    maxTemp: todayForecast?.maxTemperature,
                    minTemp: todayForecast?.minTemperature,
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Buttons (Save city + View 7-day forecast)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if (isSaved) {
                              await savedCitiesProvider.removeCity(city.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${city.name} removed from saved cities')),
                              );
                            } else {
                              final success = await savedCitiesProvider.addCity(city);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${city.name} added to saved cities!')),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                            color: isSaved ? Theme.of(context).colorScheme.primary : null,
                          ),
                          label: Text(isSaved ? 'Saved' : 'Save City'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WeatherDetailsScreen(city: city),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: const Text('7-Day Forecast'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Details Grid: Humidity, Wind, Pressure, Sunrise/Sunset
                  Text(
                    'Weather Highlights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      WeatherDetailCard(
                        title: 'Humidity',
                        value: '${weather.relativeHumidity}%',
                        subtitle: weather.relativeHumidity > 70 ? 'High moisture' : 'Comfortable',
                        icon: Icons.water_drop_outlined,
                        iconColor: Colors.blueAccent,
                      ),
                      WeatherDetailCard(
                        title: 'Wind Speed',
                        value: settings.formatWindSpeed(weather.windSpeed),
                        subtitle: 'Direction: ${weather.windDirection}°',
                        icon: Icons.air_rounded,
                        iconColor: Colors.teal,
                      ),
                      WeatherDetailCard(
                        title: 'Pressure',
                        value: '${weather.surfacePressure.round()} hPa',
                        subtitle: 'Atmospheric',
                        icon: Icons.compress_rounded,
                        iconColor: Colors.indigo,
                      ),
                      WeatherDetailCard(
                        title: 'Rain Chance',
                        value: '${todayForecast?.precipitationProbability ?? 0}%',
                        subtitle: 'Today\'s peak prob.',
                        icon: Icons.umbrella_outlined,
                        iconColor: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
