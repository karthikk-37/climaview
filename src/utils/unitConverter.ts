import { WeatherSettings } from '../types/weather';

export function formatTemp(celsius: number, settings: WeatherSettings, showSymbol = true): string {
  if (settings.temperatureUnit === 'fahrenheit') {
    const f = (celsius * 9) / 5 + 32;
    return `${Math.round(f)}${showSymbol ? '°F' : '°'}`;
  }
  return `${Math.round(celsius)}${showSymbol ? '°C' : '°'}`;
}

export function formatWind(kmh: number, settings: WeatherSettings): string {
  if (settings.windSpeedUnit === 'mph') {
    const mph = kmh * 0.621371;
    return `${mph.toFixed(1)} mph`;
  }
  return `${kmh.toFixed(1)} km/h`;
}

export function formatPrecip(mm: number, settings: WeatherSettings): string {
  if (settings.precipitationUnit === 'inch') {
    const inch = mm * 0.0393701;
    return `${inch.toFixed(2)} in`;
  }
  return `${mm.toFixed(1)} mm`;
}
