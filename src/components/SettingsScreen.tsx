import React from 'react';
import { ArrowLeft, Thermometer, Wind, CloudRain, RotateCcw, Info } from 'lucide-react';
import { WeatherSettings, TemperatureUnit, WindSpeedUnit, PrecipitationUnit } from '../types/weather';

interface SettingsScreenProps {
  settings: WeatherSettings;
  onUpdateSettings: (newSettings: Partial<WeatherSettings>) => void;
  onResetDefaults: () => void;
  onBack: () => void;
}

export const SettingsScreen: React.FC<SettingsScreenProps> = ({
  settings,
  onUpdateSettings,
  onResetDefaults,
  onBack,
}) => {
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
              Settings & Units
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400">Application Preferences</p>
          </div>
        </div>
      </div>

      {/* Settings Form List */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {/* Unit Preferences Header */}
        <div>
          <h4 className="text-xs font-bold text-blue-600 dark:text-blue-400 uppercase tracking-wider mb-1">
            Measurement Units
          </h4>
          <p className="text-xs text-slate-500 dark:text-slate-400">
            Selected units automatically apply across dashboard, detail forecasts, and bookmarks.
          </p>
        </div>

        {/* Temperature Unit */}
        <div className="p-4 bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 space-y-3">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-orange-50 dark:bg-orange-950/50 text-orange-600 dark:text-orange-400 flex items-center justify-center">
              <Thermometer className="w-4 h-4" />
            </div>
            <div>
              <p className="text-sm font-bold text-slate-900 dark:text-white">Temperature</p>
              <p className="text-xs text-slate-400">Celsius or Fahrenheit scales</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 p-1 bg-slate-100 dark:bg-slate-800/80 rounded-xl">
            {(['celsius', 'fahrenheit'] as TemperatureUnit[]).map((unit) => {
              const active = settings.temperatureUnit === unit;
              return (
                <button
                  key={unit}
                  onClick={() => onUpdateSettings({ temperatureUnit: unit })}
                  className={`py-2 text-xs font-semibold rounded-lg transition-all ${
                    active
                      ? 'bg-white dark:bg-slate-700 text-blue-600 dark:text-blue-400 shadow-xs'
                      : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
                  }`}
                >
                  {unit === 'celsius' ? 'Celsius (°C)' : 'Fahrenheit (°F)'}
                </button>
              );
            })}
          </div>
        </div>

        {/* Wind Speed Unit */}
        <div className="p-4 bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 space-y-3">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-teal-50 dark:bg-teal-950/50 text-teal-600 dark:text-teal-400 flex items-center justify-center">
              <Wind className="w-4 h-4" />
            </div>
            <div>
              <p className="text-sm font-bold text-slate-900 dark:text-white">Wind Speed</p>
              <p className="text-xs text-slate-400">Kilometers per hour or Miles per hour</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 p-1 bg-slate-100 dark:bg-slate-800/80 rounded-xl">
            {(['kmh', 'mph'] as WindSpeedUnit[]).map((unit) => {
              const active = settings.windSpeedUnit === unit;
              return (
                <button
                  key={unit}
                  onClick={() => onUpdateSettings({ windSpeedUnit: unit })}
                  className={`py-2 text-xs font-semibold rounded-lg transition-all ${
                    active
                      ? 'bg-white dark:bg-slate-700 text-blue-600 dark:text-blue-400 shadow-xs'
                      : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
                  }`}
                >
                  {unit === 'kmh' ? 'km/h' : 'mph'}
                </button>
              );
            })}
          </div>
        </div>

        {/* Precipitation Unit */}
        <div className="p-4 bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 space-y-3">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-blue-50 dark:bg-blue-950/50 text-blue-600 dark:text-blue-400 flex items-center justify-center">
              <CloudRain className="w-4 h-4" />
            </div>
            <div>
              <p className="text-sm font-bold text-slate-900 dark:text-white">Precipitation</p>
              <p className="text-xs text-slate-400">Rainfall depth units</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 p-1 bg-slate-100 dark:bg-slate-800/80 rounded-xl">
            {(['mm', 'inch'] as PrecipitationUnit[]).map((unit) => {
              const active = settings.precipitationUnit === unit;
              return (
                <button
                  key={unit}
                  onClick={() => onUpdateSettings({ precipitationUnit: unit })}
                  className={`py-2 text-xs font-semibold rounded-lg transition-all ${
                    active
                      ? 'bg-white dark:bg-slate-700 text-blue-600 dark:text-blue-400 shadow-xs'
                      : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
                  }`}
                >
                  {unit === 'mm' ? 'Millimeters (mm)' : 'Inches (in)'}
                </button>
              );
            })}
          </div>
        </div>

        {/* Reset Defaults */}
        <button
          onClick={onResetDefaults}
          className="w-full py-3 px-4 rounded-2xl border border-slate-200 dark:border-slate-800 text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 flex items-center justify-center gap-2 transition-colors active:scale-98"
        >
          <RotateCcw className="w-3.5 h-3.5" />
          Reset to Metric Defaults (°C, km/h, mm)
        </button>

        {/* About App Info */}
        <div className="p-4 bg-blue-50/50 dark:bg-blue-950/20 rounded-2xl border border-blue-100 dark:border-blue-950 flex items-start gap-3">
          <Info className="w-4 h-4 text-blue-600 dark:text-blue-400 shrink-0 mt-0.5" />
          <div className="text-xs text-slate-600 dark:text-slate-400">
            <p className="font-semibold text-slate-800 dark:text-slate-200">
              SharedPreferences Persistence
            </p>
            <p className="mt-0.5">
              Unit preferences are immediately synchronized to device storage and broadcast through the Provider tree without restarting.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
