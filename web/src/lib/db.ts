import { supabase, isSupabaseConfigured } from './supabase';

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
      
      console.error('Supabase newsletter subscribe failed (falling back to local storage):', error);
    } catch (err: any) {
      console.error('Supabase newsletter subscribe error (falling back to local storage):', err);
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

export interface SupportMessage {
  id: string | number;
  name: string;
  email: string;
  message: string;
  timestamp: string;
}

export async function sendSupportMessage(name: string, email: string, message: string): Promise<{ success: boolean; message: string }> {
  if (isSupabaseConfigured && supabase) {
    try {
      const { error } = await supabase
        .from('support_messages')
        .insert([{ name, email, message }]);

      if (!error) {
        return { success: true, message: 'Message sent successfully!' };
      }
      console.error('Supabase support message failed (falling back to local storage):', error);
    } catch (err: any) {
      console.error('Supabase support message error (falling back to local storage):', err);
    }
  }

  // Local Storage Fallback
  if (typeof window !== 'undefined') {
    const rawMsgs = localStorage.getItem('classsync_mock_support_messages');
    const messages: SupportMessage[] = rawMsgs ? JSON.parse(rawMsgs) : [];

    const newMsg: SupportMessage = {
      id: `mock_${Date.now()}`,
      name,
      email,
      message,
      timestamp: new Date().toISOString(),
    };

    messages.unshift(newMsg);
    localStorage.setItem('classsync_mock_support_messages', JSON.stringify(messages));
    return { success: true, message: 'Message recorded locally!' };
  }

  return { success: false, message: 'Local storage not available.' };
}

export async function getSupportMessages(): Promise<SupportMessage[]> {
  if (isSupabaseConfigured && supabase) {
    try {
      const { data, error } = await supabase
        .from('support_messages')
        .select('*')
        .order('timestamp', { ascending: false })
        .limit(50);

      if (!error && data) {
        return data.map(d => ({
          id: d.id,
          name: d.name,
          email: d.email,
          message: d.message,
          timestamp: d.timestamp,
        }));
      }
      console.error('Supabase fetch support messages failed:', error);
    } catch (err) {
      console.error('Supabase support messages error:', err);
    }
  }

  // Local Storage Fallback
  if (typeof window !== 'undefined') {
    const rawMsgs = localStorage.getItem('classsync_mock_support_messages');
    const list: SupportMessage[] = rawMsgs ? JSON.parse(rawMsgs) : [];
    
    // If list is empty, pre-populate some mock data
    if (list.length === 0) {
      const mockList: SupportMessage[] = [
        { id: 1, name: 'Dhruva', email: 'dhruva@college.edu', message: 'Hey! Is there a light mode theme option coming in the next release? Love the dark theme, but light mode would be great for outdoors.', timestamp: new Date(Date.now() - 1000 * 60 * 15).toISOString() },
        { id: 2, name: 'Alice Smith', email: 'alice.s@university.edu', message: 'I tried importing my friends timetable sync code but it failed with error 404. Can you check if the sync servers are up?', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString() },
        { id: 3, name: 'Rohan Mehta', email: 'rohanm@techinst.edu', message: 'Amazing work on the attendance calculator! It has saved me from falling below 75% so many times already.', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 5).toISOString() },
      ];
      localStorage.setItem('classsync_mock_support_messages', JSON.stringify(mockList));
      return mockList;
    }
    return list;
  }

  return [];
}
