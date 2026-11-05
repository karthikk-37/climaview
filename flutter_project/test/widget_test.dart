import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:climaview/models/weather_settings_model.dart';
import 'package:climaview/providers/settings_provider.dart';
import 'package:climaview/providers/saved_cities_provider.dart';
import 'package:climaview/screens/saved_cities_screen.dart';

void main() {
  group('ClimaView College Project Tests (GP11)', () {
    test('Unit Conversion Formulas Test', () {
      final settings = SettingsProvider();

      // Celsius default
      expect(settings.formatTemperature(25.0), '25°C');

      // Convert to Fahrenheit
      settings.setTemperatureUnit(TemperatureUnit.fahrenheit);
      expect(settings.formatTemperature(0.0), '32°F');
      expect(settings.formatTemperature(100.0), '212°F');

      // Wind speed default km/h
      expect(settings.formatWindSpeed(10.0), '10.0 km/h');

      // Convert to mph
      settings.setWindSpeedUnit(WindSpeedUnit.mph);
      expect(settings.formatWindSpeed(10.0), '6.2 mph');

      // Precipitation
      expect(settings.formatPrecipitation(25.4), '1.00 in');
    });

    testWidgets('Saved Cities Screen displays Empty State when list is empty (GP3, GP11)', (WidgetTester tester) async {
      final savedProvider = SavedCitiesProvider();
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: savedProvider),
            ChangeNotifierProvider.value(value: settingsProvider),
          ],
          child: const MaterialApp(
            home: SavedCitiesScreen(),
          ),
        ),
      );

      // Verify that empty state graphic text appears
      expect(find.text('No Saved Cities Yet'), findsOneWidget);
      expect(find.text('Add a City Now'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });
  });
}
