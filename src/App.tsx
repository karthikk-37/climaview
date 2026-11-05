import React, { useState, useEffect } from 'react';
import {
  Sun,
  Search,
  Bookmark,
  Settings as SettingsIcon,
  Home,
  FileCode,
  Smartphone,
  Maximize2,
  RefreshCw,
  Wifi,
  Battery,
} from 'lucide-react';
import { City, CurrentWeather, DailyForecast, WeatherSettings } from './types/weather';
import { fetchWeatherAndForecast } from './services/openMeteo';
import { HomeScreen } from './components/HomeScreen';
import { ForecastScreen } from './components/ForecastScreen';
import { SavedCitiesScreen } from './components/SavedCitiesScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { SearchModal } from './components/SearchModal';
import { FlutterHubModal } from './components/FlutterHubModal';

type ActiveScreen = 'home' | 'forecast' | 'saved' | 'settings';

const DEFAULT_CITY: City = {
  id: 2643743,
  name: 'London',
  latitude: 51.50853,
  longitude: -0.12574,
  country: 'United Kingdom',
  admin1: 'England',
};

const DEFAULT_SETTINGS: WeatherSettings = {
  temperatureUnit: 'celsius',
  windSpeedUnit: 'kmh',
  precipitationUnit: 'mm',
};

export default function App() {
  const [activeScreen, setActiveScreen] = useState<ActiveScreen>('home');
  const [currentCity, setCurrentCity] = useState<City>(() => {
    try {
      const stored = localStorage.getItem('climaview_last_city');
      return stored ? JSON.parse(stored) : DEFAULT_CITY;
    } catch {
      return DEFAULT_CITY;
    }
  });

  const [currentWeather, setCurrentWeather] = useState<CurrentWeather | null>(null);
  const [forecast, setForecast] = useState<DailyForecast[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const [savedCities, setSavedCities] = useState<City[]>(() => {
    try {
      const stored = localStorage.getItem('climaview_saved_cities');
      return stored
        ? JSON.parse(stored)
        : [
            { id: 1850147, name: 'Tokyo', latitude: 35.6895, longitude: 139.6917, country: 'Japan' },
            { id: 5128581, name: 'New York', latitude: 40.7143, longitude: -74.006, country: 'United States' },
            { id: 2988507, name: 'Paris', latitude: 48.8534, longitude: 2.3488, country: 'France' },
          ];
    } catch {
      return [];
    }
  });

  const [cachedWeather, setCachedWeather] = useState<Record<number, CurrentWeather>>({});
  const [savedLoading, setSavedLoading] = useState<boolean>(false);
  const [savedError, setSavedError] = useState<string | null>(null);

  const [settings, setSettings] = useState<WeatherSettings>(() => {
    try {
      const stored = localStorage.getItem('climaview_settings');
      return stored ? JSON.parse(stored) : DEFAULT_SETTINGS;
    } catch {
      return DEFAULT_SETTINGS;
    }
  });

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [isHubOpen, setIsHubOpen] = useState(false);
  const [isDeviceFrame, setIsDeviceFrame] = useState(true);

  // Load weather for active city
  const loadWeatherData = async (city: City) => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchWeatherAndForecast(city.latitude, city.longitude);
      setCurrentWeather(data.current);
      setForecast(data.forecast);
      setCurrentCity(city);
      localStorage.setItem('climaview_last_city', JSON.stringify(city));
    } catch (err: any) {
      setError(err.message || 'Failed to fetch weather data from Open-Meteo API.');
    } finally {
      setLoading(false);
    }
  };

  // Load weather metrics for saved cities
  const refreshSavedCitiesWeather = async (cities: City[]) => {
    if (cities.length === 0) return;
    setSavedLoading(true);
    setSavedError(null);
    try {
      const newMap: Record<number, CurrentWeather> = {};
      await Promise.all(
        cities.map(async (c) => {
          try {
            const data = await fetchWeatherAndForecast(c.latitude, c.longitude);
            newMap[c.id] = data.current;
          } catch {
            // keep old if exists
          }
        })
      );
      setCachedWeather((prev) => ({ ...prev, ...newMap }));
    } catch (err: any) {
      setSavedError(err.message || 'Could not refresh saved cities weather');
    } finally {
      setSavedLoading(false);
    }
  };

  useEffect(() => {
    loadWeatherData(currentCity);
  }, []);

  useEffect(() => {
    refreshSavedCitiesWeather(savedCities);
  }, [savedCities.length]);

  // Persist saved cities to localStorage (mirrors SharedPreferences)
  const handleToggleSaveCity = () => {
    if (!currentCity) return;
    const exists = savedCities.some((c) => c.id === currentCity.id);
    if (exists) {
      const filtered = savedCities.filter((c) => c.id !== currentCity.id);
      setSavedCities(filtered);
      localStorage.setItem('climaview_saved_cities', JSON.stringify(filtered));
    } else {
      const updated = [...savedCities, currentCity];
      setSavedCities(updated);
      localStorage.setItem('climaview_saved_cities', JSON.stringify(updated));
      if (currentWeather) {
        setCachedWeather((prev) => ({ ...prev, [currentCity.id]: currentWeather }));
      }
    }
  };

  const handleRemoveSavedCity = (cityId: number) => {
    const filtered = savedCities.filter((c) => c.id !== cityId);
    setSavedCities(filtered);
    localStorage.setItem('climaview_saved_cities', JSON.stringify(filtered));
  };

  const handleSelectCity = (city: City) => {
    loadWeatherData(city);
    setActiveScreen('home');
  };

  const handleUpdateSettings = (newSettings: Partial<WeatherSettings>) => {
    setSettings((prev) => {
      const updated = { ...prev, ...newSettings };
      localStorage.setItem('climaview_settings', JSON.stringify(updated));
      return updated;
    });
  };

  const handleResetSettings = () => {
    setSettings(DEFAULT_SETTINGS);
    localStorage.setItem('climaview_settings', JSON.stringify(DEFAULT_SETTINGS));
  };

  const isCurrentCitySaved = currentCity ? savedCities.some((c) => c.id === currentCity.id) : false;

  const currentTimeStr = new Date().toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col items-center justify-center p-0 sm:p-4 select-none font-sans">
      {/* Top Bar for Evaluator & Viva Demo */}
      <header className="w-full max-w-5xl px-4 py-3 flex items-center justify-between text-xs border-b border-slate-800 mb-2">
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-lg bg-blue-600 text-white flex items-center justify-center font-bold">
            <Sun className="w-4 h-4" />
          </div>
          <div>
            <span className="font-bold text-white text-sm">ClimaView</span>
            <span className="ml-2 text-[11px] text-slate-400">Android Weather Capstone (Flutter & Open-Meteo)</span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Toggle Phone Frame vs Full width */}
          <button
            onClick={() => setIsDeviceFrame(!isDeviceFrame)}
            className="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 flex items-center gap-1.5 transition-colors"
            title="Toggle Device Frame"
          >
            {isDeviceFrame ? <Maximize2 className="w-3.5 h-3.5" /> : <Smartphone className="w-3.5 h-3.5" />}
            <span className="hidden sm:inline">{isDeviceFrame ? 'Full Viewport' : 'Android Frame'}</span>
          </button>

          {/* Open College Viva & Code Hub */}
          <button
            onClick={() => setIsHubOpen(true)}
            className="px-3 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-500 text-white font-semibold flex items-center gap-1.5 shadow-sm transition-all"
          >
            <FileCode className="w-3.5 h-3.5" />
            <span>Flutter Codebase & Viva Hub</span>
          </button>
        </div>
      </header>

      {/* Main Container / Mobile Device Simulation */}
      <main
        className={`w-full transition-all duration-300 flex flex-col justify-center items-center ${
          isDeviceFrame ? 'max-w-[412px] h-[860px]' : 'max-w-4xl h-[860px]'
        }`}
      >
        <div
          className={`w-full h-full bg-slate-50 dark:bg-slate-950 text-slate-900 dark:text-slate-100 flex flex-col overflow-hidden relative shadow-2xl ${
            isDeviceFrame
              ? 'rounded-[44px] border-[10px] border-slate-800 ring-1 ring-slate-700'
              : 'rounded-2xl border border-slate-800'
          }`}
        >
          {/* Android Status Bar (GP7 Material 3 mobile posture) */}
          <div className="h-10 px-6 flex items-center justify-between text-xs font-semibold text-slate-700 dark:text-slate-300 bg-transparent shrink-0 z-20">
            <span className="font-mono-tabular">{currentTimeStr}</span>
            {/* Camera cutout notch simulation */}
            {isDeviceFrame && (
              <div className="w-4 h-4 rounded-full bg-slate-800 border border-slate-700 mx-auto" />
            )}
            <div className="flex items-center gap-2">
              <Wifi className="w-3.5 h-3.5" />
              <Battery className="w-4 h-4" />
            </div>
          </div>

          {/* Screen Content Router */}
          <div className="flex-1 flex flex-col overflow-hidden relative">
            {activeScreen === 'home' && (
              <HomeScreen
                city={currentCity}
                weather={currentWeather}
                forecast={forecast}
                settings={settings}
                loading={loading}
                error={error}
                isSaved={isCurrentCitySaved}
                onOpenSearch={() => setIsSearchOpen(true)}
                onOpenForecast={() => setActiveScreen('forecast')}
                onOpenSavedCities={() => setActiveScreen('saved')}
                onOpenSettings={() => setActiveScreen('settings')}
                onToggleSaveCity={handleToggleSaveCity}
                onRefresh={() => loadWeatherData(currentCity)}
              />
            )}

            {activeScreen === 'forecast' && (
              <ForecastScreen
                city={currentCity}
                forecast={forecast}
                settings={settings}
                onBack={() => setActiveScreen('home')}
              />
            )}

            {activeScreen === 'saved' && (
              <SavedCitiesScreen
                savedCities={savedCities}
                cachedWeather={cachedWeather}
                settings={settings}
                loading={savedLoading}
                error={savedError}
                onBack={() => setActiveScreen('home')}
                onSelectCity={handleSelectCity}
                onRemoveCity={handleRemoveSavedCity}
                onOpenSearch={() => setIsSearchOpen(true)}
                onRefresh={() => refreshSavedCitiesWeather(savedCities)}
              />
            )}

            {activeScreen === 'settings' && (
              <SettingsScreen
                settings={settings}
                onUpdateSettings={handleUpdateSettings}
                onResetDefaults={handleResetSettings}
                onBack={() => setActiveScreen('home')}
              />
            )}
          </div>

          {/* Android Bottom Navigation Bar (thumb zone ergonomics) */}
          <nav className="h-16 border-t border-slate-200/80 dark:border-slate-800 bg-white/95 dark:bg-slate-900/95 backdrop-blur-md flex items-center justify-around px-4 shrink-0 z-20">
            <button
              onClick={() => setActiveScreen('home')}
              className={`flex flex-col items-center justify-center gap-1 transition-colors ${
                activeScreen === 'home'
                  ? 'text-blue-600 dark:text-blue-400 font-bold'
                  : 'text-slate-400 hover:text-slate-600 dark:hover:text-slate-300'
              }`}
            >
              <Home className="w-5 h-5" />
              <span className="text-[10px]">Dashboard</span>
            </button>

            <button
              onClick={() => setIsSearchOpen(true)}
              className="flex flex-col items-center justify-center gap-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-300 transition-colors"
            >
              <Search className="w-5 h-5" />
              <span className="text-[10px]">Search</span>
            </button>

            <button
              onClick={() => setActiveScreen('saved')}
              className={`flex flex-col items-center justify-center gap-1 transition-colors relative ${
                activeScreen === 'saved'
                  ? 'text-blue-600 dark:text-blue-400 font-bold'
                  : 'text-slate-400 hover:text-slate-600 dark:hover:text-slate-300'
              }`}
            >
              <Bookmark className="w-5 h-5" />
              <span className="text-[10px]">Saved</span>
              {savedCities.length > 0 && (
                <span className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-blue-600 text-white text-[9px] font-bold flex items-center justify-center">
                  {savedCities.length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveScreen('settings')}
              className={`flex flex-col items-center justify-center gap-1 transition-colors ${
                activeScreen === 'settings'
                  ? 'text-blue-600 dark:text-blue-400 font-bold'
                  : 'text-slate-400 hover:text-slate-600 dark:hover:text-slate-300'
              }`}
            >
              <SettingsIcon className="w-5 h-5" />
              <span className="text-[10px]">Settings</span>
            </button>
          </nav>

          {/* Android Gesture Bar Pill */}
          {isDeviceFrame && (
            <div className="h-4 bg-white dark:bg-slate-900 flex items-center justify-center pb-1">
              <div className="w-28 h-1 bg-slate-300 dark:bg-slate-700 rounded-full" />
            </div>
          )}
        </div>
      </main>

      {/* City Search Form Modal (GP4) */}
      <SearchModal
        isOpen={isSearchOpen}
        onClose={() => setIsSearchOpen(false)}
        onSelectCity={handleSelectCity}
      />

      {/* Flutter Hub & College Viva Modal */}
      <FlutterHubModal
        isOpen={isHubOpen}
        onClose={() => setIsHubOpen(false)}
      />
    </div>
  );
}
