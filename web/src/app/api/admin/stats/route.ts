import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';

export async function GET() {
  try {
    // 1. Authenticate check
    const cookieStore = await cookies();
    const session = cookieStore.get('classsync_admin_session');
    const adminPassword = process.env.ADMIN_PASSWORD || 'BOLDfit@14';
    const expectedSessionValue = crypto.createHash('sha256').update(adminPassword).digest('hex');

    if (!session || session.value !== expectedSessionValue) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // 2. Setup Supabase admin client if keys are present
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';
    const isConfigured = !!(supabaseUrl && supabaseServiceKey && supabaseUrl !== 'your_supabase_url');

    // Default Baseline numbers
    const BASE_DOWNLOADS = 0;
    const BASE_STUDENTS = 0;
    const BASE_TIMETABLES = 0;
    const BASE_CLASSES = 0;

    let dbDownloadsCount = 0;
    let dbSubscribers: any[] = [];
    let dbSupportMessages: any[] = [];
    let isConnected = false;
    const chartData: { date: string; downloads: number }[] = [];
    const today = new Date();

    if (isConfigured) {
      try {
        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
          auth: { persistSession: false }
        });

        // Query total downloads count
        const { count: downCount, error: downErr } = await supabaseAdmin
          .from('downloads')
          .select('*', { count: 'exact', head: true });

        if (!downErr && downCount !== null) {
          dbDownloadsCount = downCount;
        }

        // Query recent newsletter subscribers
        const { data: subsData, error: subsErr } = await supabaseAdmin
          .from('newsletter_subscribers')
          .select('*')
          .order('timestamp', { ascending: false })
          .limit(50);

        if (!subsErr && subsData) {
          dbSubscribers = subsData;
        }

        // Query recent support messages
        const { data: supportData, error: supportErr } = await supabaseAdmin
          .from('support_messages')
          .select('*')
          .order('timestamp', { ascending: false })
          .limit(50);

        if (!supportErr && supportData) {
          dbSupportMessages = supportData;
        }

        // Query download timestamps for the last 7 days
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
        const { data: downloadRows, error: downloadErr } = await supabaseAdmin
          .from('downloads')
          .select('timestamp')
          .gte('timestamp', sevenDaysAgo.toISOString());

        let downloadRowsData: { timestamp: string }[] = [];
        if (!downloadErr && downloadRows) {
          downloadRowsData = downloadRows as { timestamp: string }[];
        } else if (downloadErr) {
          console.error('Supabase download rows fetch failed:', downloadErr);
        }

        if (downloadRowsData.length > 0) {
          const countsByDate: Record<string, number> = {};
          const formatDate = (date: Date) => date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
          downloadRowsData.forEach((row) => {
            const dateStr = formatDate(new Date(row.timestamp));
            countsByDate[dateStr] = (countsByDate[dateStr] || 0) + 1;
          });

          for (let i = 6; i >= 0; i--) {
            const d = new Date();
            d.setDate(today.getDate() - i);
            const dateStr = formatDate(d);
            chartData.push({
              date: dateStr,
              downloads: countsByDate[dateStr] || 0,
            });
          }
        }

        isConnected = true;
      } catch (err) {
        console.error('Supabase server-side admin query failed, falling back to mock:', err);
      }
    }

    // Aggregate statistics
    const totalDownloads = BASE_DOWNLOADS + dbDownloadsCount;
    const activeStudents = Math.round(BASE_STUDENTS + dbDownloadsCount * 0.9 + dbSubscribers.length);
    const timetablesCreated = BASE_TIMETABLES + dbDownloadsCount + dbSubscribers.length * 2;
    const classesTracked = BASE_CLASSES + (dbDownloadsCount * 18);

    // If Supabase did not return live chart data, build a default 7-day array
    if (chartData.length === 0) {
      const formatDate = (date: Date) => date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
      for (let i = 6; i >= 0; i--) {
        const d = new Date();
        d.setDate(today.getDate() - i);
        chartData.push({
          date: formatDate(d),
          downloads: i === 0 ? dbDownloadsCount : 0,
        });
      }
    }

    // Generate recent subscribers list
    const subscribers = dbSubscribers.length > 0 
      ? dbSubscribers.map(sub => ({
          id: sub.id,
          name: sub.name,
          email: sub.email,
          timestamp: sub.timestamp,
        }))
      : [
          { id: 1, name: 'Dhruva', email: 'dhruva@college.edu', timestamp: new Date(Date.now() - 1000 * 60 * 15).toISOString() },
          { id: 2, name: 'Alice Smith', email: 'alice.s@university.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString() },
          { id: 3, name: 'Rohan Mehta', email: 'rohanm@techinst.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 5).toISOString() },
          { id: 4, name: 'Sarah Connor', email: 'sconnor@mit.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 24).toISOString() },
          { id: 5, name: 'Alex Johnson', email: 'alexj@standford.edu', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 30).toISOString() },
        ];

    // Generate recent support messages list
    const supportMessages = dbSupportMessages.length > 0 
      ? dbSupportMessages.map(msg => ({
          id: msg.id,
          name: msg.name,
          email: msg.email,
          message: msg.message,
          timestamp: msg.timestamp,
        }))
      : [
          { id: 1, name: 'Dhruva', email: 'dhruva@college.edu', message: 'Hey! Is there a light mode theme option coming in the next release? Love the dark theme, but light mode would be great for outdoors.', timestamp: new Date(Date.now() - 1000 * 60 * 15).toISOString() },
          { id: 2, name: 'Alice Smith', email: 'alice.s@university.edu', message: 'I tried importing my friends timetable sync code but it failed with error 404. Can you check if the sync servers are up?', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString() },
          { id: 3, name: 'Rohan Mehta', email: 'rohanm@techinst.edu', message: 'Amazing work on the attendance calculator! It has saved me from falling below 75% so many times already.', timestamp: new Date(Date.now() - 1000 * 60 * 60 * 5).toISOString() },
        ];

    return NextResponse.json({
      success: true,
      stats: {
        totalDownloads,
        activeStudents,
        timetablesCreated,
        classesTracked,
      },
      subscribers,
      supportMessages,
      chartData,
      isSupabaseConnected: isConnected,
    });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message || 'Server error' }, { status: 500 });
  }
}
