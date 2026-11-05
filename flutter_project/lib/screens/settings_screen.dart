import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_settings_model.dart';
import '../providers/settings_provider.dart';

/// Screen 4: Settings & Measurement Unit Preferences (GP1)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section: Unit Preferences
          Text(
            'Unit Preferences',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Temperature Unit Card
          _buildSettingsCard(
            context: context,
            title: 'Temperature',
            subtitle: 'Displayed across dashboard and forecasts',
            child: SegmentedButton<TemperatureUnit>(
              segments: const [
                ButtonSegment(
                  value: TemperatureUnit.celsius,
                  label: Text('Celsius (°C)'),
                  icon: Icon(Icons.thermostat_outlined),
                ),
                ButtonSegment(
                  value: TemperatureUnit.fahrenheit,
                  label: Text('Fahrenheit (°F)'),
                  icon: Icon(Icons.thermostat_rounded),
                ),
              ],
              selected: {settingsProvider.tempUnit},
              onSelectionChanged: (newSelection) {
                settingsProvider.setTemperatureUnit(newSelection.first);
              },
            ),
          ),
          const SizedBox(height: 14),

          // Wind Speed Unit Card
          _buildSettingsCard(
            context: context,
            title: 'Wind Speed',
            subtitle: 'Velocity metric in weather highlights',
            child: SegmentedButton<WindSpeedUnit>(
              segments: const [
                ButtonSegment(
                  value: WindSpeedUnit.kmh,
                  label: Text('km/h'),
                  icon: Icon(Icons.speed_rounded),
                ),
                ButtonSegment(
                  value: WindSpeedUnit.mph,
                  label: Text('mph'),
                  icon: Icon(Icons.speed_outlined),
                ),
              ],
              selected: {settingsProvider.windUnit},
              onSelectionChanged: (newSelection) {
                settingsProvider.setWindSpeedUnit(newSelection.first);
              },
            ),
          ),
          const SizedBox(height: 14),

          // Precipitation Unit Card
          _buildSettingsCard(
            context: context,
            title: 'Precipitation',
            subtitle: 'Rainfall accumulation measurement',
            child: SegmentedButton<PrecipitationUnit>(
              segments: const [
                ButtonSegment(
                  value: PrecipitationUnit.mm,
                  label: Text('Millimeters (mm)'),
                ),
                ButtonSegment(
                  value: PrecipitationUnit.inch,
                  label: Text('Inches (in)'),
                ),
              ],
              selected: {settingsProvider.precipUnit},
              onSelectionChanged: (newSelection) {
                settingsProvider.setPrecipitationUnit(newSelection.first);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Reset to defaults button
          OutlinedButton.icon(
            onPressed: () async {
              await settingsProvider.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferences reset to default metric units.')),
              );
            },
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Reset All Settings to Default'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 32),

          // Section: About & Viva Info
          Text(
            'About ClimaView',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ClimaView v1.0.0 (Release Build)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Final-Year Computer Science Project. Powered by Open-Meteo REST API, Provider ChangeNotifier Architecture, and SharedPreferences persistence.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
