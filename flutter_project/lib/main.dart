import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/weather_provider.dart';
import 'providers/saved_cities_provider.dart';
import 'providers/settings_provider.dart';
import 'services/weather_api_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Android system overlay style (transparent status bar for full-bleed feel)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize shared storage service
  final storageService = StorageService();
  final apiService = WeatherApiService();

  runApp(
    ClimaViewApp(
      storageService: storageService,
      apiService: apiService,
    ),
  );
}

/// Root Application Widget with MultiProvider setup (GP6, GP7)
class ClimaViewApp extends StatelessWidget {
  final StorageService storageService;
  final WeatherApiService apiService;

  const ClimaViewApp({
    Key? key,
    required this.storageService,
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService: storageService)..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => SavedCitiesProvider(
            storageService: storageService,
            apiService: apiService,
          )..loadSavedCities(),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(
            apiService: apiService,
            storageService: storageService,
          )..initializeDefaultCity(),
        ),
      ],
      child: MaterialApp(
        title: 'ClimaView',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
