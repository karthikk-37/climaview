import { City, CurrentWeather, DailyForecast } from '../types/weather';

const GEO_URL = 'https://geocoding-api.open-meteo.com/v1/search';
const WEATHER_URL = 'https://api.open-meteo.com/v1/forecast';

export async function searchCities(query: string): Promise<City[]> {
  const clean = query.trim();
  if (!clean) return [];

  const url = `${GEO_URL}?name=${encodeURIComponent(clean)}&count=6&language=en&format=json`;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 10000);

  try {
    const res = await fetch(url, { signal: controller.signal });
    clearTimeout(timeoutId);

    if (!res.ok) {
      throw new Error(`Geocoding server error (${res.status})`);
    }

    const data = await res.json();
    if (data.results && Array.isArray(data.results)) {
      return data.results.map((item: any) => ({
        id: item.id || Math.floor(Math.random() * 100000),
        name: item.name || 'Unknown',
        latitude: item.latitude,
        longitude: item.longitude,
        country: item.country || 'Unknown Country',
        admin1: item.admin1,
      }));
    }
    return [];
  } catch (err: any) {
    if (err.name === 'AbortError') {
      throw new Error('Search request timed out. Please check your connection.');
    }
    throw err;
  }
}

export async function fetchWeatherAndForecast(
  latitude: number,
  longitude: number
): Promise<{ current: CurrentWeather; forecast: DailyForecast[] }> {
  const url = `${WEATHER_URL}?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max&timezone=auto`;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 10000);

  try {
    const res = await fetch(url, { signal: controller.signal });
    clearTimeout(timeoutId);

    if (!res.ok) {
      throw new Error(`Weather server error (${res.status})`);
    }

    const data = await res.json();
    const cur = data.current || {};
    const daily = data.daily || {};

    const current: CurrentWeather = {
      temperature: cur.temperature_2m ?? 0,
      apparentTemperature: cur.apparent_temperature ?? 0,
      relativeHumidity: cur.relative_humidity_2m ?? 0,
      windSpeed: cur.wind_speed_10m ?? 0,
      windDirection: cur.wind_direction_10m ?? 0,
      surfacePressure: cur.surface_pressure ?? 1013,
      weatherCode: cur.weather_code ?? 0,
      time: cur.time || new Date().toISOString(),
    };

    const dates = daily.time || [];
    const codes = daily.weather_code || [];
    const maxs = daily.temperature_2m_max || [];
    const mins = daily.temperature_2m_min || [];
    const precips = daily.precipitation_probability_max || [];
    const winds = daily.wind_speed_10m_max || [];

    const forecast: DailyForecast[] = dates.map((date: string, i: number) => ({
      date,
      weatherCode: codes[i] ?? 0,
      maxTemperature: maxs[i] ?? 0,
      minTemperature: mins[i] ?? 0,
      precipitationProbability: precips[i] ?? 0,
      maxWindSpeed: winds[i] ?? 0,
    }));

    return { current, forecast };
  } catch (err: any) {
    if (err.name === 'AbortError') {
      throw new Error('Weather request timed out. Open-Meteo took too long to reply.');
    }
    throw err;
  }
}
