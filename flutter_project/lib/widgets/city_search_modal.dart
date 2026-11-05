import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/city_model.dart';

/// Form Modal for searching cities with rigorous validation (GP1, GP4)
class CitySearchModal extends StatefulWidget {
  final Function(CityModel) onCitySelected;

  const CitySearchModal({Key? key, required this.onCitySelected}) : super(key: key);

  @override
  State<CitySearchModal> createState() => _CitySearchModalState();
}

class _CitySearchModalState extends State<CitySearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_formKey.currentState?.validate() ?? false) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      weatherProvider.searchCities(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Search City',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Form with validation (GP4)
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Enter city name (e.g., Tokyo, Paris)',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<WeatherProvider>(context, listen: false).clearSearch();
                  },
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a city name';
                }
                if (value.trim().length > 60) {
                  return 'City name must be under 60 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
          // Results consumer
          Consumer<WeatherProvider>(
            builder: (context, provider, _) {
              if (provider.isSearching) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (provider.searchError != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.parseBorder(BorderSide(color: Colors.amber.withOpacity(0.4))),
                  ),
                  child: Text(
                    provider.searchError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber[900], fontSize: 13),
                  ),
                );
              }

              if (provider.searchResults.isNotEmpty) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: provider.searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final city = provider.searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${city.admin1 != null ? "${city.admin1}, " : ""}${city.country}'),
                        onTap: () {
                          widget.onCitySelected(city);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
