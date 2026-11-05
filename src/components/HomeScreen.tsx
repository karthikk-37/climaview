import React from 'react';
import {
  Sun,
  Cloud,
  CloudRain,
  CloudSnow,
  CloudLightning,
  CloudFog,
  CloudDrizzle,
  Droplets,
  Wind,
  Gauge,
  Umbrella,
  Bookmark,
  BookmarkCheck,
  Calendar,
  RefreshCw,
  AlertTriangle,
  MapPin,
} from 'lucide-react';
import { City, CurrentWeather, DailyForecast, WeatherSettings } from '../types/weather';
import { getWMOInfo } from '../utils/wmoCodes';
import { formatTemp, formatWind } from '../utils/unitConverter';

interface HomeScreenProps {
  city: City | null;
  weather: CurrentWeather | null;
  forecast: DailyForecast[];
  settings: WeatherSettings;
  loading: boolean;
  error: string | null;
  isSaved: boolean;
  onOpenSearch: () => void;
  onOpenForecast: () => void;
  onOpenSavedCities: () => void;
  onOpenSettings: () => void;
  onToggleSaveCity: () => void;
  onRefresh: () => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({
  city,
  weather,
  forecast,
  settings,
  loading,
  error,
  isSaved,
  onOpenSearch,
  onOpenForecast,
  onToggleSaveCity,
  onRefresh,
}) => {
  const renderWeatherIcon = (iconName: string, className = 'w-16 h-16') => {
    switch (iconName) {
      case 'sun':
        return <Sun className={`${className} text-amber-300 drop-shadow-md`} />;
      case 'cloud':
        return <Cloud className={`${className} text-slate-100 drop-shadow-md`} />;
      case 'cloud-rain':
        return <CloudRain className={`${className} text-sky-200 drop-shadow-md`} />;
      case 'cloud-snow':
        return <CloudSnow className={`${className} text-cyan-100 drop-shadow-md`} />;
      case 'cloud-lightning':
        return <CloudLightning className={`${className} text-amber-300 drop-shadow-md`} />;
      case 'cloud-fog':
        return <CloudFog className={`${className} text-slate-200 drop-shadow-md`} />;
      case 'cloud-drizzle':
        return <CloudDrizzle className={`${className} text-blue-200 drop-shadow-md`} />;
      default:
        return <Sun className={`${className} text-amber-300`} />;
    }
  };

  if (loading) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-8 text-center">
        <div className="w-16 h-16 rounded-full bg-blue-50 dark:bg-blue-950/60 flex items-center justify-center mb-4">
          <RefreshCw className="w-8 h-8 text-blue-600 dark:text-blue-400 animate-spin" />
        </div>
        <h4 className="text-base font-bold text-slate-900 dark:text-white mb-1">
          Loading Meteorological Data
        </h4>
        <p className="text-xs text-slate-500 dark:text-slate-400 max-w-xs">
          Fetching live atmospheric measurements from Open-Meteo REST service...
        </p>
      </div>
    );
  }

  if (error || !city || !weather) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-8 text-center">
        <div className="w-14 h-14 rounded-full bg-red-50 dark:bg-red-950/40 text-red-500 flex items-center justify-center mb-4">
          <AlertTriangle className="w-7 h-7" />
        </div>
        <h4 className="text-base font-bold text-slate-900 dark:text-white mb-1">
          {error ? 'Weather Data Unavailable' : 'No City Selected'}
        </h4>
        <p className="text-xs text-slate-500 dark:text-slate-400 max-w-xs mb-6">
          {error || 'Search for a city or pick one from saved cities to view live forecasts.'}
        </p>
        <div className="flex items-center gap-3">
          <button
            onClick={onRefresh}
            className="px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-semibold flex items-center gap-2 shadow-sm transition-all"
          >
            <RefreshCw className="w-3.5 h-3.5" />
            Try Again
          </button>
          <button
            onClick={onOpenSearch}
            className="px-4 py-2.5 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 text-slate-700 dark:text-slate-300 rounded-xl text-xs font-semibold transition-all"
          >
            Search City
          </button>
        </div>
      </div>
    );
  }

  const wmo = getWMOInfo(weather.weatherCode);
  const todayForecast = forecast[0];

  return (
    <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
      {/* Hero Weather Card with Dynamic Weather Gradient */}
      <div
        className={`relative overflow-hidden rounded-3xl bg-linear-to-br ${wmo.gradient} p-6 text-white shadow-xl shadow-blue-500/10 transition-all duration-300`}
      >
        {/* Ambient background blur circle */}
        <div className="absolute -top-12 -right-12 w-44 h-44 rounded-full bg-white/10 blur-2xl pointer-events-none" />

        <div className="relative z-10 flex flex-col items-center text-center">
          {/* Location Title */}
          <div className="flex items-center gap-1.5 px-3 py-1 bg-white/15 backdrop-blur-md rounded-full text-xs font-medium tracking-wide mb-2">
            <MapPin className="w-3.5 h-3.5" />
            <span className="font-semibold">{city.name}</span>
            <span className="opacity-80">· {city.country}</span>
          </div>

          {/* Condition Icon */}
          <div className="my-2">{renderWeatherIcon(wmo.iconName, 'w-20 h-20')}</div>

          {/* Large Temperature Display */}
          <div className="text-7xl font-extrabold tracking-tighter my-1 font-display">
            {formatTemp(weather.temperature, settings)}
          </div>

          {/* Weather Description */}
          <div className="text-lg font-semibold tracking-tight">{wmo.description}</div>

          {/* Feels-like and High/Low */}
          <div className="mt-2 text-xs font-medium text-white/90 flex items-center gap-2">
            <span>Feels like {formatTemp(weather.apparentTemperature, settings)}</span>
            {todayForecast && (
              <>
                <span className="opacity-60">·</span>
                <span>
                  H: {formatTemp(todayForecast.maxTemperature, settings, false)}° L:{' '}
                  {formatTemp(todayForecast.minTemperature, settings, false)}°
                </span>
              </>
            )}
          </div>
        </div>
      </div>

      {/* Action Buttons (Save City & 7-Day Forecast) */}
      <div className="grid grid-cols-2 gap-3">
        <button
          onClick={onToggleSaveCity}
          className={`h-12 px-4 rounded-2xl border text-xs font-semibold flex items-center justify-center gap-2 transition-all active:scale-98 ${
            isSaved
              ? 'bg-blue-50 dark:bg-blue-950/40 border-blue-200 dark:border-blue-900 text-blue-600 dark:text-blue-400'
              : 'bg-white dark:bg-slate-800/80 border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-800'
          }`}
        >
          {isSaved ? (
            <>
              <BookmarkCheck className="w-4 h-4 text-blue-600 dark:text-blue-400" />
              <span>Saved in List</span>
            </>
          ) : (
            <>
              <Bookmark className="w-4 h-4 text-slate-500" />
              <span>Save City</span>
            </>
          )}
        </button>

        <button
          onClick={onOpenForecast}
          className="h-12 px-4 rounded-2xl bg-blue-600 hover:bg-blue-700 active:scale-98 text-white text-xs font-semibold flex items-center justify-center gap-2 shadow-sm transition-all"
        >
          <Calendar className="w-4 h-4" />
          <span>7-Day Forecast</span>
        </button>
      </div>

      {/* Weather Highlights Section */}
      <div>
        <div className="flex items-center justify-between mb-2.5">
          <h4 className="text-xs font-bold text-slate-700 dark:text-slate-300 uppercase tracking-wider">
            Atmospheric Metrics
          </h4>
          <span className="text-[11px] text-slate-400">Live API</span>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {/* Humidity */}
          <div className="p-4 bg-white dark:bg-slate-800/80 rounded-2xl border border-slate-200/80 dark:border-slate-800 flex flex-col justify-between">
            <div className="flex items-center gap-2 text-slate-500 dark:text-slate-400">
              <div className="w-7 h-7 rounded-lg bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 flex items-center justify-center">
                <Droplets className="w-4 h-4" />
              </div>
              <span className="text-xs font-medium">Humidity</span>
            </div>
            <div className="mt-3">
              <span className="text-2xl font-bold text-slate-900 dark:text-white font-mono-tabular">
                {weather.relativeHumidity}%
              </span>
              <p className="text-[11px] text-slate-400 mt-0.5">
                {weather.relativeHumidity > 70
                  ? 'High humidity'
                  : weather.relativeHumidity < 30
                  ? 'Dry air'
                  : 'Comfortable'}
              </p>
            </div>
          </div>

          {/* Wind Speed */}
          <div className="p-4 bg-white dark:bg-slate-800/80 rounded-2xl border border-slate-200/80 dark:border-slate-800 flex flex-col justify-between">
            <div className="flex items-center gap-2 text-slate-500 dark:text-slate-400">
              <div className="w-7 h-7 rounded-lg bg-teal-50 dark:bg-teal-950/60 text-teal-600 dark:text-teal-400 flex items-center justify-center">
                <Wind className="w-4 h-4" />
              </div>
              <span className="text-xs font-medium">Wind Speed</span>
            </div>
            <div className="mt-3">
              <span className="text-2xl font-bold text-slate-900 dark:text-white font-mono-tabular">
                {formatWind(weather.windSpeed, settings)}
              </span>
              <p className="text-[11px] text-slate-400 mt-0.5">
                Dir: {weather.windDirection}°
              </p>
            </div>
          </div>

          {/* Pressure */}
          <div className="p-4 bg-white dark:bg-slate-800/80 rounded-2xl border border-slate-200/80 dark:border-slate-800 flex flex-col justify-between">
            <div className="flex items-center gap-2 text-slate-500 dark:text-slate-400">
              <div className="w-7 h-7 rounded-lg bg-indigo-50 dark:bg-indigo-950/60 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
                <Gauge className="w-4 h-4" />
              </div>
              <span className="text-xs font-medium">Air Pressure</span>
            </div>
            <div className="mt-3">
              <span className="text-2xl font-bold text-slate-900 dark:text-white font-mono-tabular">
                {Math.round(weather.surfacePressure)} <span className="text-xs font-normal">hPa</span>
              </span>
              <p className="text-[11px] text-slate-400 mt-0.5">Surface level</p>
            </div>
          </div>

          {/* Precipitation Chance */}
          <div className="p-4 bg-white dark:bg-slate-800/80 rounded-2xl border border-slate-200/80 dark:border-slate-800 flex flex-col justify-between">
            <div className="flex items-center gap-2 text-slate-500 dark:text-slate-400">
              <div className="w-7 h-7 rounded-lg bg-amber-50 dark:bg-amber-950/60 text-amber-600 dark:text-amber-400 flex items-center justify-center">
                <Umbrella className="w-4 h-4" />
              </div>
              <span className="text-xs font-medium">Rain Chance</span>
            </div>
            <div className="mt-3">
              <span className="text-2xl font-bold text-slate-900 dark:text-white font-mono-tabular">
                {todayForecast?.precipitationProbability ?? 0}%
              </span>
              <p className="text-[11px] text-slate-400 mt-0.5">Today's peak chance</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
