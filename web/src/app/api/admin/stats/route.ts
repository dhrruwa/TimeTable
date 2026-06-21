import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { createClient } from '@supabase/supabase-js';
import { ADMIN_COOKIE, isValidSessionToken } from '@/lib/admin-auth';

interface Row {
  id: string | number;
  name: string;
  email: string;
  message?: string;
  timestamp: string;
}

export async function GET() {
  try {
    // 1. Authenticate with the signed, self-expiring session token.
    const cookieStore = await cookies();
    const session = cookieStore.get(ADMIN_COOKIE);
    if (!isValidSessionToken(session?.value)) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // 2. Supabase admin client (service-role key bypasses RLS for true counts).
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
    const supabaseServiceKey =
      process.env.SUPABASE_SERVICE_ROLE_KEY ||
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
      '';
    const isConfigured = !!(
      supabaseUrl &&
      supabaseServiceKey &&
      supabaseUrl !== 'your_supabase_url'
    );

    const today = new Date();
    const formatDate = (date: Date) =>
      date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

    // Build an empty 7-day chart skeleton (real data fills it in below).
    const chartData: { date: string; downloads: number }[] = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(today.getDate() - i);
      chartData.push({ date: formatDate(d), downloads: 0 });
    }

    let totalDownloads = 0;
    let subscribersCount = 0;
    let supportCount = 0;
    let subscribers: Row[] = [];
    let supportMessages: Row[] = [];
    let isConnected = false;

    if (isConfigured) {
      try {
        const db = createClient(supabaseUrl, supabaseServiceKey, {
          auth: { persistSession: false },
        });

        // Exact row counts — the real numbers.
        const [downloadsHead, subsHead, supportHead] = await Promise.all([
          db.from('downloads').select('*', { count: 'exact', head: true }),
          db.from('newsletter_subscribers').select('*', { count: 'exact', head: true }),
          db.from('support_messages').select('*', { count: 'exact', head: true }),
        ]);

        totalDownloads = downloadsHead.count ?? 0;
        subscribersCount = subsHead.count ?? 0;
        supportCount = supportHead.count ?? 0;

        // Recent lists for the tables (real rows only).
        const [subsData, supportData] = await Promise.all([
          db
            .from('newsletter_subscribers')
            .select('*')
            .order('timestamp', { ascending: false })
            .limit(50),
          db
            .from('support_messages')
            .select('*')
            .order('timestamp', { ascending: false })
            .limit(50),
        ]);
        subscribers = (subsData.data as Row[]) ?? [];
        supportMessages = (supportData.data as Row[]) ?? [];

        // Real 7-day download chart.
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
        sevenDaysAgo.setHours(0, 0, 0, 0);
        const { data: downloadRows } = await db
          .from('downloads')
          .select('timestamp')
          .gte('timestamp', sevenDaysAgo.toISOString());

        if (downloadRows) {
          const byDate: Record<string, number> = {};
          (downloadRows as { timestamp: string }[]).forEach((r) => {
            const key = formatDate(new Date(r.timestamp));
            byDate[key] = (byDate[key] || 0) + 1;
          });
          for (const point of chartData) {
            point.downloads = byDate[point.date] || 0;
          }
        }

        isConnected = true;
      } catch (err) {
        console.error('Supabase admin query failed:', err);
        isConnected = false;
      }
    }

    const downloads7d = chartData.reduce((sum, p) => sum + p.downloads, 0);

    // Every number below is a real count from the database (or 0 when there is
    // genuinely no data / no connection). No synthetic multipliers, no mock rows.
    return NextResponse.json({
      success: true,
      stats: {
        totalDownloads,
        subscribers: subscribersCount,
        supportMessages: supportCount,
        downloads7d,
      },
      subscribers: subscribers.map((s) => ({
        id: s.id,
        name: s.name,
        email: s.email,
        timestamp: s.timestamp,
      })),
      supportMessages: supportMessages.map((m) => ({
        id: m.id,
        name: m.name,
        email: m.email,
        message: m.message,
        timestamp: m.timestamp,
      })),
      chartData,
      isSupabaseConnected: isConnected,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Server error';
    return NextResponse.json({ success: false, error: message }, { status: 500 });
  }
}
