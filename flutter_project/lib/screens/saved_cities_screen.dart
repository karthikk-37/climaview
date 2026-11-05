import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_cities_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/saved_city_card.dart';
import '../widgets/city_search_modal.dart';

/// Screen 3: Saved Cities Screen with full state support (GP1, GP3)
class SavedCitiesScreen extends StatefulWidget {
  const SavedCitiesScreen({Key? key}) : super(key: key);

  @override
  State<SavedCitiesScreen> createState() => _SavedCitiesScreenState();
}

class _SavedCitiesScreenState extends State<SavedCitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedCitiesProvider>(context, listen: false).loadSavedCities();
    });
  }

  void _openSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CitySearchModal(
        onCitySelected: (city) {
          final savedProvider = Provider.of<SavedCitiesProvider>(context, listen: false);
          savedProvider.addCity(city);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Cities',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: 'Add City',
            onPressed: () => _openSearchModal(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<SavedCitiesProvider>(
        builder: (context, savedProvider, _) {
          // 1. Loading State (GP3)
          if (savedProvider.status == SavedCitiesStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading saved locations...'),
                ],
              ),
            );
          }

          // 2. Error State with retry (GP3)
          if (savedProvider.status == SavedCitiesStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      savedProvider.errorMessage ?? 'Could not retrieve saved cities.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => savedProvider.loadSavedCities(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Empty State (GP3)
          if (savedProvider.savedCities.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Saved Cities Yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bookmark your favourite destinations to quickly view live weather updates here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _openSearchModal(context),
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Add a City Now'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 4. Populated List (GP3)
          final cities = savedProvider.savedCities;
          final cache = savedProvider.cityWeatherCache;

          return RefreshIndicator(
            onRefresh: () => savedProvider.loadSavedCities(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: cities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final city = cities[index];
                final weather = cache[city.id];
                return SavedCityCard(
                  city: city,
                  weather: weather,
                  onTap: () {
                    // Load selected city into weather provider and navigate back
                    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
                    weatherProvider.fetchWeatherForCity(city);
                    Navigator.pop(context);
                  },
                  onDelete: () {
                    savedProvider.removeCity(city.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${city.name} removed.')),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
