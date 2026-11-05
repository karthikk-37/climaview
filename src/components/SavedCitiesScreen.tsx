import React, { useState } from 'react';
import {
  ArrowLeft,
  Plus,
  Trash2,
  MapPin,
  Bookmark,
  Sun,
  Cloud,
  CloudRain,
  AlertCircle,
  RefreshCw,
} from 'lucide-react';
import { City, CurrentWeather, WeatherSettings } from '../types/weather';
import { getWMOInfo } from '../utils/wmoCodes';
import { formatTemp } from '../utils/unitConverter';

interface SavedCitiesScreenProps {
  savedCities: City[];
  cachedWeather: Record<number, CurrentWeather>;
  settings: WeatherSettings;
  loading: boolean;
  error: string | null;
  onBack: () => void;
  onSelectCity: (city: City) => void;
  onRemoveCity: (cityId: number) => void;
  onOpenSearch: () => void;
  onRefresh: () => void;
}

export const SavedCitiesScreen: React.FC<SavedCitiesScreenProps> = ({
  savedCities,
  cachedWeather,
  settings,
  loading,
  error,
  onBack,
  onSelectCity,
  onRemoveCity,
  onOpenSearch,
  onRefresh,
}) => {
  const [cityToDelete, setCityToDelete] = useState<City | null>(null);

  const renderWeatherIcon = (code?: number) => {
    if (code === undefined) return <Sun className="w-5 h-5 text-amber-500" />;
    const wmo = getWMOInfo(code);
    switch (wmo.iconName) {
      case 'cloud':
        return <Cloud className="w-5 h-5 text-slate-400" />;
      case 'cloud-rain':
      case 'cloud-drizzle':
        return <CloudRain className="w-5 h-5 text-blue-500" />;
      default:
        return <Sun className="w-5 h-5 text-amber-500" />;
    }
  };

  return (
    <div className="flex-1 flex flex-col overflow-hidden bg-slate-50 dark:bg-slate-950">
      {/* Top Bar */}
      <div className="p-4 border-b border-slate-200/80 dark:border-slate-800 bg-white dark:bg-slate-900 flex items-center justify-between shrink-0">
        <div className="flex items-center gap-3">
          <button
            onClick={onBack}
            className="w-9 h-9 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 flex items-center justify-center text-slate-600 dark:text-slate-300 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white leading-tight">
              Saved Cities
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              {savedCities.length} {savedCities.length === 1 ? 'location' : 'locations'} bookmarked
            </p>
          </div>
        </div>

        <button
          onClick={onOpenSearch}
          className="w-9 h-9 rounded-full bg-blue-50 dark:bg-blue-950/60 hover:bg-blue-100 text-blue-600 dark:text-blue-400 flex items-center justify-center transition-colors"
          title="Add City"
        >
          <Plus className="w-5 h-5" />
        </button>
      </div>

      {/* Main Content matching GP3: Loading, Error, Empty, Populated */}
      <div className="flex-1 overflow-y-auto p-4">
        {/* State 1: Loading (GP3) */}
        {loading && (
          <div className="py-16 flex flex-col items-center justify-center text-center">
            <RefreshCw className="w-7 h-7 text-blue-600 animate-spin mb-3" />
            <p className="text-xs text-slate-500">Loading saved locations & live metrics...</p>
          </div>
        )}

        {/* State 2: Error with Retry (GP3) */}
        {error && !loading && (
          <div className="py-16 flex flex-col items-center justify-center text-center px-4">
            <div className="w-12 h-12 rounded-full bg-red-50 dark:bg-red-950/40 text-red-500 flex items-center justify-center mb-3">
              <AlertCircle className="w-6 h-6" />
            </div>
            <h4 className="text-sm font-bold text-slate-900 dark:text-white mb-1">
              Failed to load saved cities
            </h4>
            <p className="text-xs text-slate-500 max-w-xs mb-4">{error}</p>
            <button
              onClick={onRefresh}
              className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-semibold flex items-center gap-2"
            >
              <RefreshCw className="w-3.5 h-3.5" />
              Retry
            </button>
          </div>
        )}

        {/* State 3: Empty State (GP3) */}
        {!loading && !error && savedCities.length === 0 && (
          <div className="py-16 flex flex-col items-center justify-center text-center px-4">
            <div className="w-16 h-16 rounded-full bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 flex items-center justify-center mb-4">
              <Bookmark className="w-8 h-8" />
            </div>
            <h4 className="text-base font-bold text-slate-900 dark:text-white mb-1">
              No Saved Cities Yet
            </h4>
            <p className="text-xs text-slate-500 dark:text-slate-400 max-w-xs mb-6">
              Bookmark your favourite destinations to quickly view live weather updates here without searching every time.
            </p>
            <button
              onClick={onOpenSearch}
              className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 active:scale-95 text-white rounded-xl text-xs font-semibold flex items-center gap-2 shadow-sm transition-all"
            >
              <Plus className="w-4 h-4" />
              Add a City Now
            </button>
          </div>
        )}

        {/* State 4: Populated List (GP3) */}
        {!loading && savedCities.length > 0 && (
          <div className="space-y-3">
            {savedCities.map((city) => {
              const weather = cachedWeather[city.id];
              const wmo = weather ? getWMOInfo(weather.weatherCode) : null;

              return (
                <div
                  key={city.id}
                  className="p-3.5 bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 flex items-center justify-between gap-3 shadow-2xs hover:border-blue-300 dark:hover:border-blue-900 transition-all cursor-pointer group"
                  onClick={() => onSelectCity(city)}
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center shrink-0">
                      {renderWeatherIcon(weather?.weatherCode)}
                    </div>
                    <div className="min-w-0">
                      <p className="text-sm font-bold text-slate-900 dark:text-white truncate group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
                        {city.name}
                      </p>
                      <p className="text-xs text-slate-500 dark:text-slate-400 truncate">
                        {city.admin1 ? `${city.admin1}, ` : ''}{city.country}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    {weather && (
                      <div className="text-right">
                        <div className="text-xl font-extrabold text-slate-900 dark:text-white font-mono-tabular">
                          {formatTemp(weather.temperature, settings)}
                        </div>
                        <div className="text-[11px] text-slate-400 truncate max-w-[80px]">
                          {wmo?.description}
                        </div>
                      </div>
                    )}

                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        setCityToDelete(city);
                      }}
                      className="w-8 h-8 rounded-lg hover:bg-red-50 dark:hover:bg-red-950/50 text-slate-400 hover:text-red-500 flex items-center justify-center transition-colors"
                      title="Remove city"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {cityToDelete && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-150">
          <div className="w-full max-w-xs bg-white dark:bg-slate-900 rounded-3xl p-5 shadow-2xl border border-slate-200 dark:border-slate-800 text-center">
            <div className="w-12 h-12 rounded-full bg-red-50 dark:bg-red-950/50 text-red-500 flex items-center justify-center mx-auto mb-3">
              <Trash2 className="w-6 h-6" />
            </div>
            <h4 className="text-base font-bold text-slate-900 dark:text-white mb-1">
              Remove {cityToDelete.name}?
            </h4>
            <p className="text-xs text-slate-500 dark:text-slate-400 mb-5">
              This city will be removed from your bookmarked locations.
            </p>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setCityToDelete(null)}
                className="flex-1 py-2.5 rounded-xl border border-slate-200 dark:border-slate-800 text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  onRemoveCity(cityToDelete.id);
                  setCityToDelete(null);
                }}
                className="flex-1 py-2.5 rounded-xl bg-red-600 hover:bg-red-700 text-xs font-semibold text-white transition-colors"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
