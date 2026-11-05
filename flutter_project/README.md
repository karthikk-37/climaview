# ClimaView — Android Weather Application
> Final-Year Computer Science & Engineering Capstone Project

ClimaView is a modern, responsive Android mobile weather application built with **Flutter** (Dart with full null safety). It leverages the **Open-Meteo REST API** to deliver real-time meteorological metrics and 7-day multi-day forecasts, implements **Provider with ChangeNotifier** for clean state management, and ensures offline persistence using **SharedPreferences**.

---

## 1. Project Information
- **Application Name**: ClimaView
- **Project Topic**: Mobile Weather & Meteorological Forecasting System
- **Platform**: Android (minSdkVersion: 21, targetSdkVersion: 34)
- **Framework**: Flutter (v3.35+ stable)
- **Language**: Dart (Sound Null Safety)
- **State Management**: Provider (`ChangeNotifierProvider`, `Consumer`)
- **Public API**: Open-Meteo Geocoding & Weather Forecast APIs
- **Storage**: SharedPreferences with JSON serialization

---

## 2. Key Features
1. **Global City Search**: Search any city worldwide with real-time autocompletion and region disambiguation.
2. **Current Weather Dashboard**: Real-time temperature, condition descriptions, feels-like temperature, humidity percentage, wind velocity & direction, atmospheric pressure, and peak rain probability.
3. **7-Day Weather Outlook**: Multi-day forecast with daily high/low temperatures, precipitation chances, and condition icons.
4. **Saved Cities Bookmarks**: Store favourite locations with duplicate prevention, quick weather glance, and swipe/tap deletion with confirmation dialogs.
5. **Customizable Units**:
   - Temperature: Celsius (°C) / Fahrenheit (°F)
   - Wind Speed: km/h / mph
   - Precipitation: Millimeters (mm) / Inches (in)
6. **Dynamic Atmospheric Theming**: Dynamic sky gradient palettes that adapt visually to sunny, overcast, rainy, thunderstorm, and nighttime conditions.
7. **Offline & Error Resilience**: User-friendly retry cards on network loss, 10-second timeout safety, and graceful empty states.

---

## 3. Technology Stack
- **Flutter SDK**: Mobile cross-platform UI framework.
- **Provider (v6.1.2)**: Scalable, decoupled state management.
- **http (v1.2.1)**: Asynchronous REST API networking.
- **shared_preferences (v2.2.3)**: Native Android SharedPreferences key-value persistence.
- **intl (v0.19.0)**: Date formatting and localization.

---

## 4. Public Weather API Documentation
ClimaView relies 100% on **Open-Meteo** (no API key required):
1. **Geocoding API**:
   ```
   GET https://geocoding-api.open-meteo.com/v1/search?name={query}&count=5&language=en&format=json
   ```
2. **Forecast API**:
   ```
   GET https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max&timezone=auto
   ```

---

## 5. College Mandatory Requirements Mapping (GP1–GP11)

| Requirement | Code | Implementation Details |
| :--- | :--- | :--- |
| **Minimum Screens** | **GP1** | 4 full screens: Saved Cities (List), 7-Day Forecast (Detail), City Search (Form Modal), and Settings (Unit Config). |
| **Real Data** | **GP2** | Live queries to Open-Meteo Geocoding & Forecast endpoints. No static mock weather. |
| **List Screen States** | **GP3** | Saved Cities screen implements Loading, Error with retry, Empty state with graphic, and Populated list. |
| **Form Validation** | **GP4** | City search rejects empty/whitespace strings, trims input, restricts length $\le 60$, and displays "No cities found". |
| **Detail Screen** | **GP5** | Dedicated 7-day forecast screen showing high/low temp curves, precipitation chances, and daily conditions. |
| **Provider** | **GP6** | MultiProvider with `WeatherProvider`, `SavedCitiesProvider`, and `SettingsProvider` consumed across all 4 screens. |
| **Theme & Branding** | **GP7** | Material 3 Theme with seed color, custom SVG app mark, and weather-adaptive palettes. |
| **Error Handling** | **GP8** | Try-catch blocks around all HTTP requests, network disconnection banner, timeout thresholds (10s), orientation rebuild protection. |
| **GitHub Ready** | **GP9** | Complete clean git repository layout, multi-author commit guide, structured `README.md`, and Defect Log. |
| **Release APK** | **GP10** | Detailed step-by-step instructions for `flutter build apk --release` with ProGuard and AndroidManifest permissions. |
| **Widget Test** | **GP11** | Flutter test (`test/widget_test.dart`) testing search input validation, empty state rendering, and unit conversion logic via `flutter test`. |

---

## 6. Installation & Execution Guide

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.35 or newer).
2. Install [Android Studio](https://developer.android.com/studio) with the Flutter & Dart plugins.
3. Enable **USB Debugging** on your physical Android phone (Settings > Developer Options > USB Debugging).

### Steps to Run
```bash
# 1. Clone repository
git clone https://github.com/your-username/climaview.git
cd climaview

# 2. Install dependencies
flutter pub get

# 3. Verify connected Android device
flutter devices

# 4. Run in Debug mode on device
flutter run
```

### Running Widget Tests (GP11)
```bash
flutter test
```
*Expected Output: `All tests passed!`*

---

## 7. Generating the Release APK (GP10)
To produce a standalone `.apk` file that installs directly on physical Android phones:

```bash
# Generate optimized Release APK
flutter build apk --release
```
The output file will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

Transfer this file to your phone via USB or Google Drive and install it directly!

---

## 8. Team Work Division (3 Students)

### Member 1: UI, Design & Home Screen
- **Modules**: `lib/utils/app_theme.dart`, `lib/screens/home_screen.dart`, `lib/widgets/current_weather_card.dart`, `lib/widgets/weather_detail_card.dart`.
- **Contribution**: Designed Material 3 theme, dynamic weather gradient cards, dashboard layout, and responsive widgets.

### Member 2: API, Geocoding & Forecast Details
- **Modules**: `lib/services/weather_api_service.dart`, `lib/models/`, `lib/providers/weather_provider.dart`, `lib/screens/weather_details_screen.dart`.
- **Contribution**: Integrated Open-Meteo REST APIs, JSON parsing models, WMO code decoder, and 7-day forecast screen.

### Member 3: Saved Cities, Local Storage & Settings
- **Modules**: `lib/services/storage_service.dart`, `lib/providers/saved_cities_provider.dart`, `lib/providers/settings_provider.dart`, `lib/screens/saved_cities_screen.dart`, `lib/screens/settings_screen.dart`, `test/widget_test.dart`.
- **Contribution**: Implemented SharedPreferences persistence, duplicate prevention, unit conversion formulas, and automated widget tests.

---

## 9. College Viva Questions & Answers

### Q1: Why use Provider over setState() in Flutter?
**Answer**: `setState()` only rebuilds local widget state and cannot share data across different screens. `Provider` with `ChangeNotifier` implements the Observer Pattern: when state updates in a Provider, all subscribed screens (`Consumer` widgets) rebuild automatically without prop-drilling.

### Q2: How does SharedPreferences store data on Android?
**Answer**: `SharedPreferences` persists key-value pairs as an XML file in the Android app's private sandboxed directory (`/data/data/<package_name>/shared_prefs/`). We serialize our Dart objects into JSON strings using `json.encode()` and deserialize them with `json.decode()`.

### Q3: What is the WMO Weather Code?
**Answer**: The World Meteorological Organization defines standardized numerical codes (0–99) for atmospheric phenomena. Open-Meteo returns these codes, which ClimaView decodes into user-friendly names (e.g., Code 61 = Rain) and corresponding icons.

### Q4: How does ClimaView prevent app crashes when there is no internet?
**Answer**: All HTTP requests in `WeatherApiService` are wrapped in `try-catch` blocks that catch `SocketException` (no connection) and `TimeoutException` (server delay). Instead of crashing, the app updates `WeatherProvider` with an error message and renders a clean retry screen.
