export interface WMOInfo {
  description: string;
  iconName: 'sun' | 'cloud' | 'cloud-rain' | 'cloud-snow' | 'cloud-lightning' | 'cloud-fog' | 'cloud-drizzle';
  gradient: string; // Tailwind gradient classes
  bgAccent: string;
  cardColor: string;
}

export function getWMOInfo(code: number, isNight = false): WMOInfo {
  if (isNight) {
    return {
      description: getWMODescription(code),
      iconName: code >= 95 ? 'cloud-lightning' : (code >= 61 ? 'cloud-rain' : (code >= 2 ? 'cloud' : 'sun')),
      gradient: 'from-slate-900 via-slate-800 to-indigo-950',
      bgAccent: '#3b82f6',
      cardColor: 'bg-slate-800/80',
    };
  }

  switch (code) {
    case 0:
      return {
        description: 'Clear Sky',
        iconName: 'sun',
        gradient: 'from-blue-600 via-sky-500 to-cyan-400',
        bgAccent: '#f59e0b',
        cardColor: 'bg-blue-600',
      };
    case 1:
      return {
        description: 'Mainly Clear',
        iconName: 'sun',
        gradient: 'from-blue-600 via-sky-400 to-blue-300',
        bgAccent: '#f59e0b',
        cardColor: 'bg-blue-500',
      };
    case 2:
      return {
        description: 'Partly Cloudy',
        iconName: 'cloud',
        gradient: 'from-slate-600 via-slate-500 to-sky-600',
        bgAccent: '#60a5fa',
        cardColor: 'bg-slate-600',
      };
    case 3:
      return {
        description: 'Overcast',
        iconName: 'cloud',
        gradient: 'from-slate-700 via-gray-600 to-slate-500',
        bgAccent: '#94a3b8',
        cardColor: 'bg-slate-700',
      };
    case 45:
    case 48:
      return {
        description: 'Foggy',
        iconName: 'cloud-fog',
        gradient: 'from-slate-600 via-slate-500 to-zinc-400',
        bgAccent: '#cbd5e1',
        cardColor: 'bg-slate-600',
      };
    case 51:
    case 53:
    case 55:
      return {
        description: 'Drizzle',
        iconName: 'cloud-drizzle',
        gradient: 'from-indigo-800 via-indigo-600 to-blue-500',
        bgAccent: '#818cf8',
        cardColor: 'bg-indigo-700',
      };
    case 61:
    case 63:
    case 65:
      return {
        description: 'Rain',
        iconName: 'cloud-rain',
        gradient: 'from-blue-900 via-indigo-800 to-sky-700',
        bgAccent: '#38bdf8',
        cardColor: 'bg-blue-800',
      };
    case 71:
    case 73:
    case 75:
      return {
        description: 'Snow Fall',
        iconName: 'cloud-snow',
        gradient: 'from-slate-700 via-blue-900 to-slate-400',
        bgAccent: '#e0f2fe',
        cardColor: 'bg-slate-700',
      };
    case 80:
    case 81:
    case 82:
      return {
        description: 'Rain Showers',
        iconName: 'cloud-rain',
        gradient: 'from-blue-800 via-sky-700 to-blue-500',
        bgAccent: '#38bdf8',
        cardColor: 'bg-blue-700',
      };
    case 95:
    case 96:
    case 99:
      return {
        description: 'Thunderstorm',
        iconName: 'cloud-lightning',
        gradient: 'from-purple-950 via-indigo-900 to-slate-900',
        bgAccent: '#c084fc',
        cardColor: 'bg-purple-900',
      };
    default:
      return {
        description: 'Cloudy',
        iconName: 'cloud',
        gradient: 'from-slate-700 via-slate-600 to-slate-500',
        bgAccent: '#94a3b8',
        cardColor: 'bg-slate-700',
      };
  }
}

export function getWMODescription(code: number): string {
  switch (code) {
    case 0: return 'Clear Sky';
    case 1: return 'Mainly Clear';
    case 2: return 'Partly Cloudy';
    case 3: return 'Overcast';
    case 45:
    case 48: return 'Fog';
    case 51:
    case 53:
    case 55: return 'Drizzle';
    case 61:
    case 63:
    case 65: return 'Rain';
    case 71:
    case 73:
    case 75: return 'Snow';
    case 80:
    case 81:
    case 82: return 'Rain Showers';
    case 95:
    case 96:
    case 99: return 'Thunderstorm';
    default: return 'Cloudy';
  }
}
