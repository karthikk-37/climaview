import React from 'react';
import {
  ArrowLeft,
  Droplets,
  Wind,
  Sun,
  Cloud,
  CloudRain,
  CloudSnow,
  CloudLightning,
  CloudFog,
  CloudDrizzle,
} from 'lucide-react';
import { City, DailyForecast, WeatherSettings } from '../types/weather';
import { getWMOInfo } from '../utils/wmoCodes';
import { formatTemp, formatWind } from '../utils/unitConverter';

interface ForecastScreenProps {
  city: City | null;
  forecast: DailyForecast[];
  settings: WeatherSettings;
  onBack: () => void;
}

export const ForecastScreen: React.FC<ForecastScreenProps> = ({
  city,
  forecast,
  settings,
  onBack,
}) => {
  const renderWeatherIcon = (iconName: string, className = 'w-5 h-5') => {
    switch (iconName) {
      case 'sun':
        return <Sun className={`${className} text-amber-500`} />;
      case 'cloud':
        return <Cloud className={`${className} text-slate-400`} />;
      case 'cloud-rain':
        return <CloudRain className={`${className} text-blue-500`} />;
      case 'cloud-snow':
        return <CloudSnow className={`${className} text-cyan-500`} />;
      case 'cloud-lightning':
        return <CloudLightning className={`${className} text-purple-500`} />;
      case 'cloud-fog':
        return <CloudFog className={`${className} text-slate-400`} />;
      case 'cloud-drizzle':
        return <CloudDrizzle className={`${className} text-sky-400`} />;
      default:
        return <Sun className={`${className} text-amber-500`} />;
    }
  };

  const formatDayName = (dateStr: string, index: number) => {
    if (index === 0) return 'Today';
    try {
      const date = new Date(dateStr);
      return date.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
    } catch {
      return dateStr;
    }
  };

  return (
    <div className="flex-1 flex flex-col overflow-hidden bg-slate-50 dark:bg-slate-950">
      {/* Top App Bar */}
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
              {city?.name ?? 'City'} Forecast
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400">7-Day Meteorological Outlook</p>
          </div>
        </div>
      </div>

      {/* Forecast Day Rows List */}
      <div className="flex-1 overflow-y-auto p-4 space-y-2.5">
        {forecast.map((day, idx) => {
          const wmo = getWMOInfo(day.weatherCode);
          const isToday = idx === 0;

          return (
            <div
              key={day.date}
              className={`p-3.5 rounded-2xl border transition-all ${
                isToday
                  ? 'bg-blue-50/80 dark:bg-blue-950/40 border-blue-200 dark:border-blue-900 shadow-xs'
                  : 'bg-white dark:bg-slate-900 border-slate-200/80 dark:border-slate-800'
              } flex items-center gap-3`}
            >
              {/* Day info */}
              <div className="w-24 shrink-0">
                <p
                  className={`text-sm font-semibold truncate ${
                    isToday ? 'text-blue-600 dark:text-blue-400 font-bold' : 'text-slate-900 dark:text-white'
                  }`}
                >
                  {formatDayName(day.date, idx)}
                </p>
                <p className="text-[11px] text-slate-400 truncate">{wmo.description}</p>
              </div>

              {/* Weather icon */}
              <div className="w-8 h-8 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center shrink-0">
                {renderWeatherIcon(wmo.iconName)}
              </div>

              {/* Rain Chance Bar */}
              <div className="flex-1 min-w-[70px] px-1">
                <div className="flex items-center gap-1.5 text-xs text-blue-600 dark:text-blue-400 font-medium">
                  <Droplets className="w-3.5 h-3.5 shrink-0" />
                  <span className="font-mono-tabular">{day.precipitationProbability}%</span>
                </div>
                <div className="w-full bg-slate-100 dark:bg-slate-800 h-1.5 rounded-full overflow-hidden mt-1">
                  <div
                    className="bg-blue-500 h-full rounded-full transition-all"
                    style={{ width: `${Math.min(day.precipitationProbability, 100)}%` }}
                  />
                </div>
              </div>

              {/* Wind Indicator */}
              <div className="hidden sm:flex items-center gap-1 text-[11px] text-slate-400 shrink-0">
                <Wind className="w-3 h-3 text-slate-400" />
                <span>{formatWind(day.maxWindSpeed, settings)}</span>
              </div>

              {/* High / Low Temperature */}
              <div className="text-right shrink-0">
                <div className="text-sm font-bold text-slate-900 dark:text-white font-mono-tabular">
                  {formatTemp(day.maxTemperature, settings)}
                </div>
                <div className="text-xs text-slate-400 font-mono-tabular">
                  {formatTemp(day.minTemperature, settings)}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
