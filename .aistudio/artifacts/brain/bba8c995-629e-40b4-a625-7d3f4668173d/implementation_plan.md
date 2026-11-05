# ClimaView — Android Weather Application (Flutter)
## Phase 1 Architecture & Implementation Plan

ClimaView is a production-grade, Material 3 Android weather application built using Flutter and Dart (with full null safety) for a final-year Computer Science Engineering college project. It integrates the Open-Meteo public API for real-time weather and 7-day forecasts, implements robust Provider-based state management, and persists user preferences and saved locations using SharedPreferences.

---

## User Review & Critical Decisions

> [!IMPORTANT]
> The following project choices were confirmed during Phase 1:
> - **Visual Theme**: Dynamic Material 3 with weather-adaptive sky gradients (Sunny Azure, Overcast Slate, Rainy Indigo, Thunder Violet, Night Obsidian).
> - **Team Work Division**: Structured for **3 student team members** covering UI/Theme, API/Forecast, and Storage/Settings/Testing with dedicated viva speaking points.
> - **Local Storage**: `SharedPreferences` with JSON serialization for zero-dependency persistence of saved cities and measurement units.
> - **Hybrid Delivery Strategy**: To satisfy both the **Android physical device release APK** requirement for your college submission and the **live interactive browser environment** in AI Studio:
>   1. **Complete Flutter Dart Codebase**: Production-ready, null-safe Dart files organized in `lib/` (`models/`, `services/`, `providers/`, `screens/`, `widgets/`, `utils/`), `test/widget_test.dart`, `pubspec.yaml`, `README.md`, and Defect Log, ready to build an APK via Android Studio (`flutter build apk --release`).
>   2. **Interactive Live In-Browser Android Preview**: A fully functional live companion interface running directly in your web preview matching the Material 3 Android layout and live Open-Meteo API calls so you can demonstrate the app, verify state transitions, and take screenshots immediately.

---

## 1. Overview & Core Concept

### 1.1 What It Does
ClimaView allows users to:
1. **Search Any City Worldwide**: Connects to the Open-Meteo Geocoding API with real-time autocompletion, latitude/longitude resolution, and region disambiguation.
2. **Inspect Current Weather**: Renders temperature, weather conditions (WMO code mapped to descriptive titles and icons), "feels-like" apparent temperature, relative humidity, wind speed, wind direction, atmospheric pressure, and sunrise/sunset times.
3. **Explore Multi-Day Forecasts**: Shows 7-day outlooks with high/low temperatures, precipitation probabilities, and daily wind conditions.
4. **Manage Favourite Cities**: Bookmark cities with instant duplicate prevention, persistent local storage, and one-tap removal with confirmation.
5. **Customize Measurement Units**: Seamlessly toggle between Metric and Imperial systems:
   - Temperature: Celsius (°C) / Fahrenheit (°F)
   - Wind Speed: km/h / mph
   - Precipitation: mm / inches
6. **Gracefully Handle Errors**: Zero-crash resilience against network timeouts, empty query inputs, invalid names, and device rotation.

### 1.2 Target Audience & Viva Value
- **Audience**: Mobile users needing quick, reliable weather forecasts with zero bloat and no ads.
- **Examiner Appeal**: Clean separation of concerns (MVVM architecture with Provider), 100% open-source API (no secret keys needed), robust unit testing, and full persistence.

---

## 2. User Experience & Visual Design

### 2.1 The 4 Required Screens & Navigation Flow

```
                      ┌────────────────────────────────────────┐
                      │          CLIMAVIEW DASHBOARD           │
                      │               (Screen 1)               │
                      └───────────────────┬────────────────────┘
                                          │
            ┌─────────────────────────────┼────────────────────────────┐
            ▼                             ▼                            ▼
┌───────────────────────┐     ┌───────────────────────┐    ┌───────────────────────┐
│     CITY SEARCH       │     │  WEATHER DETAILS &    │    │     SAVED CITIES      │
│     (Form Modal)      │     │   7-DAY FORECAST      │    │      (Screen 3)       │
│      (GP1 / GP4)      │     │      (Screen 2)       │    │      (GP1 / GP3)      │
└───────────────────────┘     └───────────────────────┘    └───────────┬───────────┘
                                                                       │
                                                                       ▼
                                                           ┌───────────────────────┐
                                                           │   SETTINGS & UNITS    │
                                                           │      (Screen 4)       │
                                                           │         (GP1)         │
                                                           └───────────────────────┘
```

#### Screen 1: Home / Current Weather Dashboard
- **Top Bar**: ClimaView logo, current location name & country, search button, saved cities bookmark icon, and settings gear.
- **Hero Card**: Weather condition icon, large tabular temperature typography, weather description (e.g., "Partly Cloudy"), high/low day range, and feels-like temperature.
- **Metrics Grid**: 4 to 6 Material 3 cards for Humidity (%), Wind Speed & Direction, Atmospheric Pressure (hPa), and Sunrise/Sunset times.
- **Action Strip**: Primary "7-Day Forecast" pill button and "Save City" button (changes to "Saved" if already in bookmarks).

#### Screen 2: Detailed 7-Day Weather Forecast
- **Header**: City name, current condition snapshot, and back navigation.
- **Forecast List / Cards**: 7 distinct daily rows displaying:
  - Day name and formatted date (`Mon, Nov 6`)
  - Weather icon + condition description
  - Rain probability bar (%)
  - Wind speed indicator
  - Temperature range pill (Min temp — Max temp)

#### Screen 3: Saved Cities Manager
- **List State (GP3)**: Displays all bookmarked cities with current temperature and condition badge.
- **Tapping a City**: Loads that city into the active `WeatherProvider` and switches to the home screen or detail screen.
- **Delete Action**: Swipe-to-delete or trash icon with a Material confirmation dialog.
- **Empty State**: Graphic illustration with "No saved cities yet. Search and bookmark your favourite locations."

#### Screen 4: Settings & Preferences
- **Segmented Radio Selectors**:
  - Temperature: Celsius (°C) vs Fahrenheit (°F)
  - Wind Speed: Kilometers per hour (km/h) vs Miles per hour (mph)
  - Precipitation: Millimeters (mm) vs Inches (in)
- **Immediate Persistence**: Changes instantly broadcast via `SettingsProvider` to update all screens without app reload.
- **Reset Button**: Restores standard Metric defaults.

### 2.2 Visual Theme & Dynamic Weather Palettes

The UI uses Google Material 3 standards with dynamic atmospheric color schemes derived from the current WMO weather code:
- **Clear / Sunny (WMO 0, 1)**: Azure sky gradient (`#1E88E5` to `#64B5F6`), warm golden amber accents.
- **Cloudy / Overcast (WMO 2, 3, 45, 48)**: Cool slate-blue gradient (`#455A64` to `#90A4AE`).
- **Rain / Drizzle (WMO 51–67, 80–82)**: Deep oceanic indigo gradient (`#1A237E` to `#3949AB`).
- **Thunderstorm (WMO 95–99)**: Electric violet-slate gradient (`#311B92` to `#512DA8`).
- **Night Mode**: Deep midnight obsidian (`#0F172A` to `#1E293B`) with luminescent white/cyan text.

---

## 3. Technical Architecture & Data Strategy

### 3.1 System Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER (UI)                         │
│  ┌─────────────────┐  ┌──────────────────┐  ┌───────────────────────┐  │
│  │   HomeScreen    │  │ DetailForecast   │  │   SavedCitiesScreen   │  │
│  │  (Dashboard)    │  │     Screen       │  │      & Settings       │  │
│  └────────┬────────┘  └────────┬─────────┘  └───────────┬───────────┘  │
└───────────┼────────────────────┼────────────────────────┼──────────────┘
            │                    │                        │
            ▼                    ▼                        ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    STATE MANAGEMENT LAYER (PROVIDER)                   │
│  ┌────────────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │    WeatherProvider     │  │SavedCitiesProvid│  │ SettingsProvider│  │
│  │ (Current & 7-Day Data) │  │(Bookmarks List) │  │  (Unit Toggles) │  │
│  └───────────┬────────────┘  └────────┬────────┘  └────────┬────────┘  │
└──────────────┼────────────────────────┼────────────────────┼───────────┘
               │                        │                    │
               ▼                        ▼                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        DATA & SERVICES LAYER                           │
│  ┌────────────────────────┐                  ┌──────────────────────┐  │
│  │  WeatherApiService     │                  │    StorageService    │  │
│  │ - Open-Meteo Forecast  │                  │ - SharedPreferences  │  │
│  │ - Open-Meteo Geocoding │                  │ - JSON Serialization │  │
│  └───────────┬────────────┘                  └──────────┬───────────┘  │
└──────────────┼──────────────────────────────────────────┼──────────────┘
               ▼                                          ▼
   [ Open-Meteo REST API ]                      [ Android Device Disk ]
```

### 3.2 Data Models

1. **`CityModel`** (`lib/models/city_model.dart`):
   ```dart
   class CityModel {
     final int id;
     final String name;
     final double latitude;
     final double longitude;
     final String country;
     final String? admin1; // State or province
     // toMap(), fromJson(), toJson()
   }
   ```
2. **`CurrentWeatherModel`** (`lib/models/weather_model.dart`):
   ```dart
   class CurrentWeatherModel {
     final double temperature;
     final double apparentTemperature; // feels-like
     final int relativeHumidity;
     final double windSpeed;
     final int windDirection;
     final double surfacePressure;
     final int weatherCode;
     final String time;
   }
   ```
3. **`DailyForecastModel`** (`lib/models/forecast_model.dart`):
   ```dart
   class DailyForecastModel {
     final String date;
     final int weatherCode;
     final double maxTemperature;
     final double minTemperature;
     final int precipitationProbability;
     final double maxWindSpeed;
   }
   ```
4. **`WeatherSettingsModel`** (`lib/models/weather_settings_model.dart`):
   ```dart
   enum TemperatureUnit { celsius, fahrenheit }
   enum WindSpeedUnit { kmh, mph }
   enum PrecipitationUnit { mm, inch }
   ```

### 3.3 Provider Architecture (ChangeNotifier)

- **`WeatherProvider`**:
  - State: `CityModel? currentCity`, `CurrentWeatherModel? currentWeather`, `List<DailyForecastModel> forecast`, `bool isLoading`, `String? errorMessage`.
  - Methods: `fetchWeather(CityModel city)`, `searchCities(String query)`, `refreshCurrentWeather()`.
- **`SavedCitiesProvider`**:
  - State: `List<CityModel> savedCities`, `Map<int, CurrentWeatherModel> quickWeatherMap`.
  - Methods: `loadSavedCities()`, `addCity(CityModel city)`, `removeCity(int cityId)`, `bool isCitySaved(int cityId)`.
- **`SettingsProvider`**:
  - State: `TemperatureUnit tempUnit`, `WindSpeedUnit windUnit`, `PrecipitationUnit precipUnit`.
  - Methods: `setTemperatureUnit(...)`, `setWindSpeedUnit(...)`, `setPrecipitationUnit(...)`, `convertTemp(double celsius)`, `convertWind(double kmh)`.

### 3.4 Open-Meteo Public API Integration

Open-Meteo requires **no API keys** and has zero rate limits for educational use:
1. **Geocoding API**:
   `GET https://geocoding-api.open-meteo.com/v1/search?name={query}&count=5&language=en&format=json`
2. **Forecast API**:
   `GET https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max&timezone=auto`

### 3.5 WMO Weather Code Interpretation
Open-Meteo provides international World Meteorological Organization (WMO) codes. ClimaView maps all 28 standard WMO codes to clear descriptions and Flutter icons:
- `0`: Clear Sky
- `1, 2, 3`: Mainly Clear, Partly Cloudy, Overcast
- `45, 48`: Fog and Depositing Rime Fog
- `51, 53, 55`: Drizzle (Light, Moderate, Dense)
- `61, 63, 65`: Rain (Slight, Moderate, Heavy)
- `71, 73, 75`: Snow Fall
- `80, 81, 82`: Rain Showers
- `95, 96, 99`: Thunderstorm (with Hail)

---

## 4. Compliance with College Mandatory Requirements (GP1–GP11)

| Requirement | Code | Implementation in ClimaView |
| :--- | :--- | :--- |
| **Minimum Screens** | **GP1** | 4 full screens: Saved Cities (List), 7-Day Forecast (Detail), City Search (Form Modal), and Settings (Unit Config). |
| **Real Data** | **GP2** | Live queries to Open-Meteo Geocoding & Forecast endpoints. No static mock weather. |
| **List Screen States** | **GP3** | Saved Cities screen has 4 distinct states: Loading (CircularProgress), Error (Retry card), Empty (Welcome illustration), and Populated (Interactive cards). |
| **Form Validation** | **GP4** | City search rejects empty/whitespace strings, trims input, restricts length $\le 60$, and displays "No cities found" on 0 matches. |
| **Detail Screen** | **GP5** | Dedicated 7-day forecast screen showing high/low temp curves, precipitation chances, and daily conditions. |
| **Provider** | **GP6** | MultiProvider with `WeatherProvider`, `SavedCitiesProvider`, and `SettingsProvider` consumed across all 4 screens. |
| **Theme & Branding** | **GP7** | Material 3 Theme with seed color, custom SVG app mark, and weather-adaptive palettes. |
| **Error Handling** | **GP8** | Try-catch blocks around all HTTP requests, network disconnection banner, timeout thresholds (10s), orientation rebuild protection. |
| **GitHub Ready** | **GP9** | Complete clean git repository layout, multi-author commit guide, structured `README.md`, and Defect Log. |
| **Release APK** | **GP10** | Detailed step-by-step instructions for `flutter build apk --release` with ProGuard and AndroidManifest permissions. |
| **Widget Test** | **GP11** | Flutter test (`test/widget_test.dart`) testing search input validation, empty state rendering, and unit conversion logic via `flutter test`. |

---

## 5. Team Member Work Division (3 Students)

### Member 1: UI, Design & Home Screen
- **Core Modules**: `lib/utils/app_theme.dart`, `lib/screens/home_screen.dart`, `lib/widgets/current_weather_card.dart`, `lib/widgets/weather_detail_card.dart`.
- **Responsibilities**: Material 3 theme configuration, dynamic sky gradients, home screen layout, weather icon mapping, and app logo.
- **Viva Defense Questions**:
  - *Q: How does Material 3 dynamic color theming work in Flutter?*
  - *Q: How do you format numbers and prevent layout overflow on smaller Android screens?*

### Member 2: API, Geocoding & Forecast Details
- **Core Modules**: `lib/services/weather_api_service.dart`, `lib/models/`, `lib/providers/weather_provider.dart`, `lib/screens/weather_details_screen.dart`.
- **Responsibilities**: HTTP calls to Open-Meteo endpoints, JSON parsing into models, WMO code decoder, and 7-day forecast screen.
- **Viva Defense Questions**:
  - *Q: Why choose Open-Meteo over other APIs?*
  - *Q: How does the Geocoding API resolve latitude and longitude before querying the weather?*
  - *Q: How do you handle HTTP timeouts and 5xx server errors without crashing?*

### Member 3: Saved Cities, Local Storage & Settings
- **Core Modules**: `lib/services/storage_service.dart`, `lib/providers/saved_cities_provider.dart`, `lib/providers/settings_provider.dart`, `lib/screens/saved_cities_screen.dart`, `lib/screens/settings_screen.dart`, `test/widget_test.dart`.
- **Responsibilities**: SharedPreferences integration, JSON serialization for bookmarks, unit conversion formulas, widget test suite, and Defect Log.
- **Viva Defense Questions**:
  - *Q: How does SharedPreferences persist data across app restarts on Android?*
  - *Q: Why use ChangeNotifier and notifyListeners() instead of setState()?*
  - *Q: How does the app prevent duplicate bookmarks?*

---

## 6. Phased Implementation Roadmap

1. **Phase 1: Planning & Approval (Current Turn)** — Review system architecture, models, screen list, and college requirement checklist.
2. **Phase 2: Project Setup & Dependencies** — Configure `pubspec.yaml`, AndroidManifest permissions (`INTERNET`, `ACCESS_NETWORK_STATE`), and project directory structure.
3. **Phase 3: Core Models & Services** — Implement `CityModel`, `CurrentWeatherModel`, `DailyForecastModel`, `WeatherApiService`, and `StorageService`.
4. **Phase 4: Provider State Management** — Implement `WeatherProvider`, `SavedCitiesProvider`, and `SettingsProvider` with ChangeNotifier.
5. **Phase 5: UI Widgets & Dynamic Theme** — Build reusable cards, WMO icon helper, and weather gradients.
6. **Phase 6: The 4 Core Screens** — Assemble Home Dashboard, City Search Modal, 7-Day Forecast Screen, Saved Cities Screen, and Settings Screen.
7. **Phase 7: Testing & Error Handling (GP11)** — Write and execute `test/widget_test.dart` verifying search validation and unit conversions.
8. **Phase 8: College Submission Artifacts** — Prepare `README.md`, Defect Log, screenshots guide, and APK release build instructions.
