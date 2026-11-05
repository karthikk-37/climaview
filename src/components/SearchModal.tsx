import React, { useState } from 'react';
import { Search, X, Loader2, MapPin, AlertCircle } from 'lucide-react';
import { City } from '../types/weather';
import { searchCities } from '../services/openMeteo';

interface SearchModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSelectCity: (city: City) => void;
}

export const SearchModal: React.FC<SearchModalProps> = ({ isOpen, onClose, onSelectCity }) => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<City[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleSearch = async (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    const clean = query.trim();

    // Form Validation (GP4)
    if (!clean) {
      setError('Please enter a city name to search.');
      setResults([]);
      return;
    }
    if (clean.length > 60) {
      setError('City name is too long. Please shorten your query.');
      setResults([]);
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const data = await searchCities(clean);
      setResults(data);
      if (data.length === 0) {
        setError(`No cities found matching "${clean}".`);
      }
    } catch (err: any) {
      setError(err.message || 'Failed to search cities.');
      setResults([]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div className="w-full sm:max-w-md bg-white dark:bg-slate-900 rounded-t-3xl sm:rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden flex flex-col max-h-[85vh]">
        {/* Header */}
        <div className="p-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-full bg-blue-50 dark:bg-blue-950/60 flex items-center justify-center text-blue-600 dark:text-blue-400">
              <Search className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-base font-bold text-slate-900 dark:text-white">Search City</h3>
              <p className="text-xs text-slate-500 dark:text-slate-400">Open-Meteo Geocoding API</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 flex items-center justify-center text-slate-500 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search Input Form */}
        <form onSubmit={handleSearch} className="p-4 pb-2">
          <div className="relative">
            <input
              type="text"
              autoFocus
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                if (error) setError(null);
              }}
              placeholder="e.g. Tokyo, London, New York..."
              className="w-full pl-10 pr-20 py-3 bg-slate-100 dark:bg-slate-800/80 rounded-2xl text-sm text-slate-900 dark:text-white placeholder-slate-400 focus:outline-hidden focus:ring-2 focus:ring-blue-500 border border-transparent transition-all"
            />
            <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-3.5" />
            <button
              type="submit"
              disabled={loading}
              className="absolute right-1.5 top-1.5 bottom-1.5 px-3 bg-blue-600 hover:bg-blue-700 active:scale-95 text-white rounded-xl text-xs font-semibold flex items-center justify-center transition-all disabled:opacity-50"
            >
              {loading ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : 'Search'}
            </button>
          </div>
        </form>

        {/* Quick Suggestion Chips */}
        <div className="px-4 py-2 flex items-center gap-1.5 overflow-x-auto text-xs text-slate-500">
          <span className="text-slate-400 shrink-0">Popular:</span>
          {['Tokyo', 'London', 'Paris', 'New York', 'Mumbai', 'Sydney'].map((city) => (
            <button
              key={city}
              type="button"
              onClick={() => {
                setQuery(city);
                searchCities(city).then((res) => {
                  setResults(res);
                  if (res.length === 0) setError(`No results for ${city}`);
                });
              }}
              className="px-2.5 py-1 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300 rounded-lg shrink-0 transition-colors"
            >
              {city}
            </button>
          ))}
        </div>

        {/* Results Area */}
        <div className="flex-1 overflow-y-auto p-4 pt-2 divide-y divide-slate-100 dark:divide-slate-800/60 min-h-[160px]">
          {loading && (
            <div className="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
              <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
              <span className="text-xs">Querying Open-Meteo Geocoding...</span>
            </div>
          )}

          {error && !loading && (
            <div className="py-8 flex flex-col items-center justify-center text-center px-4">
              <div className="w-10 h-10 rounded-full bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400 flex items-center justify-center mb-2">
                <AlertCircle className="w-5 h-5" />
              </div>
              <p className="text-xs font-medium text-amber-800 dark:text-amber-300">{error}</p>
            </div>
          )}

          {!loading && !error && results.length === 0 && (
            <div className="py-8 text-center text-xs text-slate-400">
              Type a city name above and tap Search to retrieve meteorological coordinates.
            </div>
          )}

          {!loading &&
            results.map((city) => (
              <button
                key={`${city.id}-${city.latitude}`}
                onClick={() => {
                  onSelectCity(city);
                  onClose();
                }}
                className="w-full text-left py-3 px-3 hover:bg-blue-50/80 dark:hover:bg-blue-950/30 rounded-xl flex items-center gap-3 transition-colors group"
              >
                <div className="w-8 h-8 rounded-lg bg-slate-100 dark:bg-slate-800 group-hover:bg-blue-100 dark:group-hover:bg-blue-900/60 text-slate-500 group-hover:text-blue-600 flex items-center justify-center transition-colors shrink-0">
                  <MapPin className="w-4 h-4" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-slate-900 dark:text-white truncate">
                    {city.name}
                  </p>
                  <p className="text-xs text-slate-500 dark:text-slate-400 truncate">
                    {city.admin1 ? `${city.admin1}, ` : ''}{city.country}
                  </p>
                </div>
                <span className="text-[11px] font-mono-tabular text-slate-400">
                  {city.latitude.toFixed(2)}°, {city.longitude.toFixed(2)}°
                </span>
              </button>
            ))}
        </div>
      </div>
    </div>
  );
};
