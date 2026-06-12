import { supabase, isSupabaseConfigured } from './supabase';

export interface Stats {
  totalDownloads: number;
  activeStudents: number;
  timetablesCreated: number;
  classesTracked: number;
}

export interface Subscriber {
  id: string | number;
  name: string;
  email: string;
  timestamp: string;
}

export interface ChartDataPoint {
  date: string;
  downloads: number;
}

// Local storage keys for mock data
const KEYS = {
  DOWNLOADS_COUNT: 'classsync_mock_downloads_count',
  SUBSCRIBERS: 'classsync_mock_subscribers',
  SESSION_DOWNLOADS: 'classsync_session_downloads',
};

// Base baseline statistics to make it look premium out of the box
const BASE_DOWNLOADS = 0;
const BASE_STUDENTS = 0;
const BASE_TIMETABLES = 0;
const BASE_CLASSES = 0;

// Helper to format date as "MMM DD"
function formatDate(date: Date): string {
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

export async function trackDownload(): Promise<boolean> {
  if (isSupabaseConfigured && supabase) {
    try {
      const { error } = await supabase.from('downloads').insert([{}]);
      if (!error) return true;
      console.error('Supabase download logging failed:', error);
    } catch (err) {
      console.error('Supabase download error:', err);
    }
  }

  // Local Storage Fallback
  if (typeof window !== 'undefined') {
    const currentSession = Number(localStorage.getItem(KEYS.SESSION_DOWNLOADS) || '0');
    localStorage.setItem(KEYS.SESSION_DOWNLOADS, String(currentSession + 1));
    return true;
  }
  return true;
}

export async function subscribeNewsletter(name: string, email: string): Promise<{ success: boolean; message: string }> {
  if (isSupabaseConfigured && supabase) {
    try {
      const { error } = await supabase
        .from('newsletter_subscribers')
        .insert([{ name, email }]);

      if (!error) {
        return { success: true, message: 'Welcome to early access!' };
      }

      if (error.code === '23505') { // Unique constraint violation (duplicate email)
        return { success: false, message: 'This email is already registered.' };
      }
      
      return { success: false, message: error.message };
    } catch (err: any) {
      return { success: false, message: err.message || 'Server error, please try again.' };
    }
  }

  // Local Storage Fallback
  if (typeof window !== 'undefined') {
    const rawSubs = localStorage.getItem(KEYS.SUBSCRIBERS);
    const subscribers: Subscriber[] = rawSubs ? JSON.parse(rawSubs) : [];

    if (subscribers.some(sub => sub.email.toLowerCase() === email.toLowerCase())) {
      return { success: false, message: 'This email is already registered.' };
    }

    const newSub: Subscriber = {
      id: `mock_${Date.now()}`,
      name,
      email,
      timestamp: new Date().toISOString(),
    };

    subscribers.unshift(newSub);
    localStorage.setItem(KEYS.SUBSCRIBERS, JSON.stringify(subscribers));
    return { success: true, message: 'Welcome to early access (Simulated)!' };
  }

  return { success: false, message: 'Local storage not available.' };
}

export async function getStats(): Promise<Stats> {
  let dbDownloadsCount = 0;
  let dbSubscribersCount = 0;

  if (isSupabaseConfigured && supabase) {
    try {
      // Get count of downloads
      const { count: downCount, error: downErr } = await supabase
        .from('downloads')
        .select('*', { count: 'exact', head: true });

      if (!downErr && downCount !== null) {
        dbDownloadsCount = downCount;
      }

      // Get count of subscribers
      const { count: subCount, error: subErr } = await supabase
        .from('newsletter_subscribers')
        .select('*', { count: 'exact', head: true });

      if (!subErr && subCount !== null) {
        dbSubscribersCount = subCount;
      }
    } catch (err) {
      console.error('Failed to fetch stats from Supabase:', err);
    }
  }

  // Calculate stats combining baseline values + database/mock values
  let additionalDownloads = dbDownloadsCount;
  let additionalSubs = dbSubscribersCount;

  if (typeof window !== 'undefined') {
    const sessionDowns = Number(localStorage.getItem(KEYS.SESSION_DOWNLOADS) || '0');
    const rawSubs = localStorage.getItem(KEYS.SUBSCRIBERS);
    const mockSubs: Subscriber[] = rawSubs ? JSON.parse(rawSubs) : [];
    
    // In mock mode, we add the session downloads and local storage subscribers
    if (!isSupabaseConfigured) {
      additionalDownloads = sessionDowns;
      additionalSubs = mockSubs.length;
    } else {
      // In Supabase mode, we also add session downloads to show instant feedback
      additionalDownloads += sessionDowns;
    }
  }

  const totalDownloads = BASE_DOWNLOADS + additionalDownloads;
  const activeStudents = Math.round(BASE_STUDENTS + additionalDownloads * 0.9 + additionalSubs);
  const timetablesCreated = BASE_TIMETABLES + additionalDownloads + additionalSubs * 2;
  const classesTracked = BASE_CLASSES + (additionalDownloads * 18);

  return {
    totalDownloads,
    activeStudents,
    timetablesCreated,
    classesTracked,
  };
}

export async function getSubscribers(): Promise<Subscriber[]> {
  if (isSupabaseConfigured && supabase) {
    try {
      const { data, error } = await supabase
        .from('newsletter_subscribers')
        .select('*')
        .order('timestamp', { ascending: false })
        .limit(50);

      if (!error && data) {
        return data.map(d => ({
          id: d.id,
          name: d.name,
          email: d.email,
          timestamp: d.timestamp,
        }));
      }
      console.error('Supabase fetch subscribers failed:', error);
    } catch (err) {
      console.error('Supabase subscribers error:', err);
    }
  }

  // Local Storage Fallback
  if (typeof window !== 'undefined') {
    const rawSubs = localStorage.getItem(KEYS.SUBSCRIBERS);
    const list: Subscriber[] = rawSubs ? JSON.parse(rawSubs) : [];
    
    // If list is empty, let's pre-populate some elegant mock ones
    if (list.length === 0) {
      const mockList: Subscriber[] = [
        { id: 1, name: 'Dhruva', email: 'dhruva@college.edu', timestamp: new Date(Date.now() - 1000 * 60 * 15).toISOString() },
        { id: 2, name: 'Alice Smith', email: 'alice.s@university.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString() },
        { id: 3, name: 'Rohan Mehta', email: 'rohanm@techinst.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 5).toISOString() },
        { id: 4, name: 'Sarah Connor', email: 'sconnor@mit.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 24).toISOString() },
        { id: 5, name: 'Alex Johnson', email: 'alexj@standford.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 30).toISOString() },
      ];
      localStorage.setItem(KEYS.SUBSCRIBERS, JSON.stringify(mockList));
      return mockList;
    }
    return list;
  }

  return [];
}

export async function getChartData(): Promise<ChartDataPoint[]> {
  // We want to return data for the last 7 days
  const data: ChartDataPoint[] = [];
  const today = new Date();

  // Create baseline downloads per day
  const baselineDownloads = [0, 0, 0, 0, 0, 0, 0]; // Daily downloads baseline

  if (isSupabaseConfigured && supabase) {
    try {
      // Fetch actual downloads grouped by day from Supabase
      // To keep it simple and avoid complex SQL queries, we'll fetch timestamps
      // and aggregate them in JS. Limit to last 300 records.
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      
      const { data: dbData, error } = await supabase
        .from('downloads')
        .select('timestamp')
        .gte('timestamp', sevenDaysAgo.toISOString());

      if (!error && dbData) {
        // Group by date
        const counts: Record<string, number> = {};
        dbData.forEach(row => {
          const dateStr = formatDate(new Date(row.timestamp));
          counts[dateStr] = (counts[dateStr] || 0) + 1;
        });

        for (let i = 6; i >= 0; i--) {
          const d = new Date();
          d.setDate(today.getDate() - i);
          const dateStr = formatDate(d);
          // Add DB downloads for this day to the baseline
          data.push({
            date: dateStr,
            downloads: baselineDownloads[6 - i] + (counts[dateStr] || 0),
          });
        }
        return data;
      }
    } catch (err) {
      console.error('Failed to get Supabase chart data, using mock:', err);
    }
  }

  // Local Storage Fallback Chart Data
  let sessionDowns = 0;
  if (typeof window !== 'undefined') {
    sessionDowns = Number(localStorage.getItem(KEYS.SESSION_DOWNLOADS) || '0');
  }

  for (let i = 6; i >= 0; i--) {
    const d = new Date();
    d.setDate(today.getDate() - i);
    const dateStr = formatDate(d);
    
    // Add all session downloads to today's data point
    const activeDownloads = baselineDownloads[6 - i] + (i === 0 ? sessionDowns : 0);
    
    data.push({
      date: dateStr,
      downloads: activeDownloads,
    });
  }

  return data;
}
