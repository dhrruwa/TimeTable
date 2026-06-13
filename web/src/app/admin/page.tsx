'use client';

import React, { useState, useEffect } from 'react';
import { Calendar, Lock, LogOut, ArrowRight, Download, Users, RefreshCw, AlertTriangle, ShieldCheck, Mail, ArrowLeft, Database, MessageSquare } from 'lucide-react';
import { motion } from 'framer-motion';

interface Stats {
  totalDownloads: number;
  activeStudents: number;
  timetablesCreated: number;
  classesTracked: number;
}

interface Subscriber {
  id: string | number;
  name: string;
  email: string;
  timestamp: string;
}

interface SupportMessage {
  id: string | number;
  name: string;
  email: string;
  message: string;
  timestamp: string;
}

interface ChartDataPoint {
  date: string;
  downloads: number;
}

export default function AdminDashboard() {
  const [password, setPassword] = useState('');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [loginError, setLoginError] = useState('');
  const [loggingIn, setLoggingIn] = useState(false);
  const [activeTab, setActiveTab] = useState<'subscribers' | 'support'>('subscribers');

  const [stats, setStats] = useState<Stats>({
    totalDownloads: 0,
    activeStudents: 0,
    timetablesCreated: 0,
    classesTracked: 0,
  });
  const [subscribers, setSubscribers] = useState<Subscriber[]>([]);
  const [supportMessages, setSupportMessages] = useState<SupportMessage[]>([]);
  const [chartData, setChartData] = useState<ChartDataPoint[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [loadingData, setLoadingData] = useState(false);

  // Check if session cookie exists on load
  useEffect(() => {
    const checkSession = async () => {
      try {
        const res = await fetch('/api/admin/stats');
        if (res.ok) {
          const data = await res.json();
          setStats(data.stats);
          setSubscribers(data.subscribers);
          setSupportMessages(data.supportMessages || []);
          setChartData(data.chartData);
          setIsConnected(data.isSupabaseConnected);
          setIsLoggedIn(true);
        }
      } catch (err) {
        // Not authenticated yet
      }
    };
    checkSession();
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!password.trim()) {
      setLoginError('Password is required.');
      return;
    }

    setLoggingIn(true);
    setLoginError('');

    try {
      const res = await fetch('/api/admin/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password }),
      });

      if (res.ok) {
        // Fetch stats immediately
        const statsRes = await fetch('/api/admin/stats');
        if (statsRes.ok) {
          const data = await statsRes.json();
          setStats(data.stats);
          setSubscribers(data.subscribers);
          setSupportMessages(data.supportMessages || []);
          setChartData(data.chartData);
          setIsConnected(data.isSupabaseConnected);
          setIsLoggedIn(true);
          setPassword('');
        }
      } else {
        const errData = await res.json();
        setLoginError(errData.message || 'Incorrect password.');
      }
    } catch (err) {
      setLoginError('Server error, please try again.');
    } finally {
      setLoggingIn(false);
    }
  };

  const handleLogout = async () => {
    // Clear session by writing a route or locally. 
    document.cookie = 'classsync_admin_session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    setIsLoggedIn(false);
    setSubscribers([]);
    setSupportMessages([]);
    setChartData([]);
  };

  const handleRefresh = async () => {
    setLoadingData(true);
    try {
      const res = await fetch('/api/admin/stats');
      if (res.ok) {
        const data = await res.json();
        setStats(data.stats);
        setSubscribers(data.subscribers);
        setSupportMessages(data.supportMessages || []);
        setChartData(data.chartData);
        setIsConnected(data.isSupabaseConnected);
      }
    } catch (err) {
      console.error('Refresh failed:', err);
    } finally {
      setLoadingData(false);
    }
  };

  // SVG Custom Chart Rendering helper
  const renderSVGChart = () => {
    if (chartData.length === 0) return null;

    const width = 600;
    const height = 250;
    const padding = 40;

    const maxVal = Math.max(...chartData.map(d => d.downloads)) * 1.2 || 100;
    const minVal = 0;

    const getX = (idx: number) => padding + (idx / (chartData.length - 1)) * (width - padding * 2);
    const getY = (val: number) => height - padding - ((val - minVal) / (maxVal - minVal)) * (height - padding * 2);

    // Create path strings
    let pathD = `M ${getX(0)} ${getY(chartData[0].downloads)}`;
    let areaD = `M ${getX(0)} ${height - padding} L ${getX(0)} ${getY(chartData[0].downloads)}`;

    for (let i = 1; i < chartData.length; i++) {
      pathD += ` L ${getX(i)} ${getY(chartData[i].downloads)}`;
      areaD += ` L ${getX(i)} ${getY(chartData[i].downloads)}`;
    }

    areaD += ` L ${getX(chartData.length - 1)} ${height - padding} Z`;

    return (
      <svg viewBox={`0 0 ${width} ${height}`} className="w-full h-full overflow-visible">
        <defs>
          <linearGradient id="chartGlow" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#1e3a8a" stopOpacity="0.15" />
            <stop offset="100%" stopColor="#0ea5e9" stopOpacity="0.0" />
          </linearGradient>
        </defs>

        {/* Horizontal grid lines */}
        {[0, 0.25, 0.5, 0.75, 1].map((r, idx) => {
          const val = Math.round(minVal + r * (maxVal - minVal));
          const y = getY(val);
          return (
            <g key={idx}>
              <line 
                x1={padding} 
                y1={y} 
                x2={width - padding} 
                y2={y} 
                stroke="rgba(15,23,42,0.06)" 
                strokeDasharray="4 4" 
              />
              <text 
                x={padding - 10} 
                y={y + 4} 
                fill="#64748b" 
                fontSize="10" 
                textAnchor="end" 
                className="font-mono font-medium"
              >
                {val}
              </text>
            </g>
          );
        })}

        {/* Graph Area Fill */}
        <path d={areaD} fill="url(#chartGlow)" />

        {/* Graph Line */}
        <path d={pathD} fill="none" stroke="#1e3a8a" strokeWidth="2.5" strokeLinecap="round" />

        {/* Data points */}
        {chartData.map((pt, idx) => {
          const cx = getX(idx);
          const cy = getY(pt.downloads);
          return (
            <g key={idx} className="group/dot cursor-pointer">
              <circle 
                cx={cx} 
                cy={cy} 
                r="4.5" 
                fill="#ffffff" 
                stroke="#0ea5e9" 
                strokeWidth="2" 
                className="transition-all hover:r-6" 
              />
              {/* Tooltip text */}
              <text
                x={cx}
                y={cy - 12}
                fill="#0f172a"
                fontSize="10"
                fontWeight="bold"
                textAnchor="middle"
                className="opacity-0 group-hover/dot:opacity-100 bg-white font-mono transition-opacity pointer-events-none"
              >
                {pt.downloads}
              </text>
            </g>
          );
        })}

        {/* X Axis Labels */}
        {chartData.map((pt, idx) => (
          <text 
            key={idx} 
            x={getX(idx)} 
            y={height - padding + 18} 
            fill="#64748b" 
            fontSize="10" 
            textAnchor="middle"
            className="font-semibold"
          >
            {pt.date}
          </text>
        ))}
      </svg>
    );
  };

  if (!isLoggedIn) {
    return (
      <div className="min-h-screen bg-white flex flex-col justify-center items-center px-4 relative overflow-hidden">
        {/* Glow dots */}
        <div className="glow-dot top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-sky-500/5 w-[450px] h-[450px] blur-[100px]"></div>

        {/* Header link back to landing page */}
        <a href="/" className="absolute top-8 left-8 flex items-center gap-1.5 text-xs text-slate-500 hover:text-slate-900 transition-colors font-semibold">
          <ArrowLeft className="w-4 h-4" /> Back to Timetable
        </a>

        {/* Login Card */}
        <div className="glass p-8 rounded-3xl w-full max-w-md border border-slate-200 bg-white shadow-2xl relative z-10 flex flex-col gap-6">
          <div className="text-center space-y-2">
            <img src="/logo.png" alt="ClassSync Logo" className="h-[60px] w-auto object-contain mx-auto" />
            <h1 className="text-xl font-bold text-slate-950 tracking-tight mt-4">Admin Security</h1>
            <p className="text-xs text-slate-500">ClassSync timetable analytics dashboard portal.</p>
          </div>

          <form onSubmit={handleLogin} className="space-y-4">
            <div className="relative">
              <Lock className="w-4.5 h-4.5 text-slate-400 absolute left-4.5 top-1/2 -translate-y-1/2" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter admin passcode"
                className="w-full pl-12 pr-4 py-3 rounded-xl bg-slate-50 border border-slate-200 text-slate-800 placeholder-slate-400 focus:outline-none focus:border-sky-500/50 text-sm transition-all shadow-2xs"
                disabled={loggingIn}
              />
            </div>

            {loginError && (
              <p className="text-xs text-rose-500 font-semibold pl-1 flex items-center gap-1">
                <AlertTriangle className="w-3.5 h-3.5 shrink-0" />
                {loginError}
              </p>
            )}

            <button
              type="submit"
              disabled={loggingIn}
              className="w-full py-3 rounded-xl bg-sky-500 hover:bg-sky-600 text-white font-bold text-sm transition-all shadow-lg shadow-sky-500/15 flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
            >
              {loggingIn ? 'Authenticating...' : 'Enter Dashboard'}
              <ArrowRight className="w-4 h-4" />
            </button>
          </form>

          <div className="pt-2 border-t border-slate-100 text-[10px] text-slate-400 leading-normal text-center font-medium">
            *Default passcode is <code className="text-slate-600 bg-slate-50 px-1 py-0.5 rounded">admin123</code>. Override this by defining the <code className="text-slate-600 bg-slate-50 px-1 py-0.5 rounded">ADMIN_PASSWORD</code> env variable.
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col font-sans relative overflow-x-hidden">
      {/* Top Header */}
      <header className="border-b border-slate-200 bg-white/75 backdrop-blur-md sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img src="/logo.png" alt="ClassSync Logo" className="h-[54px] w-auto object-contain" />
            <span className="text-[10px] text-sky-600 uppercase font-mono tracking-wider bg-sky-50 border border-sky-200 px-2 py-0.5 rounded font-bold">
              Admin Panel
            </span>
          </div>

          <div className="flex items-center gap-4">
            {/* Supabase Status Alert */}
            <div className={`hidden sm:flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-1.5 rounded-lg border ${
              isConnected 
                ? 'bg-emerald-50 border-emerald-200 text-emerald-600' 
                : 'bg-amber-50 border-amber-200 text-amber-600'
            }`}>
              {isConnected ? (
                <>
                  <ShieldCheck className="w-3.5 h-3.5" />
                  <span>SUPABASE CONNECTED</span>
                </>
              ) : (
                <>
                  <AlertTriangle className="w-3.5 h-3.5" />
                  <span>RUNNING IN SIMULATION MODE</span>
                </>
              )}
            </div>

            <button 
              onClick={handleRefresh}
              disabled={loadingData}
              className="p-2 rounded-lg bg-slate-50 border border-slate-200 text-slate-500 hover:text-slate-800 transition-colors cursor-pointer disabled:opacity-50"
            >
              <RefreshCw className={`w-4 h-4 ${loadingData ? 'animate-spin' : ''}`} />
            </button>

            <button
              onClick={handleLogout}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-50 hover:bg-slate-100 border border-slate-200 text-xs text-slate-600 font-bold cursor-pointer active:scale-95 transition-all shadow-2xs"
            >
              <LogOut className="w-3.5 h-3.5 text-rose-500" />
              <span>Log out</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main stats layout */}
      <main className="flex-grow max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-10 space-y-10">
        
        {/* Connection Notice for Developers */}
        {!isConnected && (
          <div className="glass p-5 rounded-2xl border border-amber-200 bg-amber-50/20 flex flex-col md:flex-row items-start md:items-center justify-between gap-4 text-left">
            <div className="flex gap-3">
              <AlertTriangle className="w-5 h-5 text-amber-500 mt-0.5 shrink-0" />
              <div>
                <h4 className="text-sm font-bold text-amber-800">Supabase Connection Missing</h4>
                <p className="text-xs text-slate-500 mt-0.5 leading-relaxed font-semibold">
                  The dashboard is currently running in client simulation mode. Set up <code className="text-slate-600 bg-slate-100 px-1 py-0.5 rounded font-bold">NEXT_PUBLIC_SUPABASE_URL</code>, <code className="text-slate-600 bg-slate-100 px-1 py-0.5 rounded font-bold">NEXT_PUBLIC_SUPABASE_ANON_KEY</code>, and <code className="text-slate-600 bg-slate-100 px-1 py-0.5 rounded font-bold">SUPABASE_SERVICE_ROLE_KEY</code> in environment variables to link your live data.
                </p>
              </div>
            </div>
            <a 
              href="https://supabase.com" 
              target="_blank" 
              rel="noreferrer"
              className="flex items-center gap-1.5 px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-bold text-xs shrink-0 transition-colors shadow-sm"
            >
              <Database className="w-3.5 h-3.5" /> Set up Supabase
            </a>
          </div>
        )}

        {/* Statistics Grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="glass p-6 rounded-2xl border border-slate-200 bg-white shadow-2xs flex items-start gap-4 text-left">
            <div className="p-3 rounded-xl bg-sky-50 border border-sky-100 text-sky-500">
              <Download className="w-5.5 h-5.5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider block">Total Downloads</span>
              <span className="text-2xl font-bold text-slate-900 font-mono mt-1 block">{stats.totalDownloads}</span>
            </div>
          </div>

          <div className="glass p-6 rounded-2xl border border-slate-200 bg-white shadow-2xs flex items-start gap-4 text-left">
            <div className="p-3 rounded-xl bg-indigo-50 border border-indigo-100 text-indigo-500">
              <Users className="w-5.5 h-5.5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider block">Active Students</span>
              <span className="text-2xl font-bold text-slate-900 font-mono mt-1 block">{stats.activeStudents}</span>
            </div>
          </div>

          <div className="glass p-6 rounded-2xl border border-slate-200 bg-white shadow-2xs flex items-start gap-4 text-left">
            <div className="p-3 rounded-xl bg-purple-50 border border-purple-100 text-purple-500">
              <Calendar className="w-5.5 h-5.5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider block">Schedules Created</span>
              <span className="text-2xl font-bold text-slate-900 font-mono mt-1 block">{stats.timetablesCreated}</span>
            </div>
          </div>

          <div className="glass p-6 rounded-2xl border border-slate-200 bg-white shadow-2xs flex items-start gap-4 text-left">
            <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-100 text-emerald-500">
              <Database className="w-5.5 h-5.5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider block">Classes Tracked</span>
              <span className="text-2xl font-bold text-slate-900 font-mono mt-1 block">{stats.classesTracked}</span>
            </div>
          </div>
        </div>

        {/* Charts and Tables */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-stretch">
          
          {/* Left: Download Graph */}
          <div className="lg:col-span-7 glass p-6 rounded-2xl border border-slate-200 bg-white shadow-2xs flex flex-col gap-6 text-left">
            <div>
              <h3 className="text-base font-extrabold text-slate-900">Download Growth</h3>
              <p className="text-xs text-slate-500 mt-0.5">Sideload APK downloads tracked over the last 7 days.</p>
            </div>
            
            {/* Custom SVG Line Chart */}
            <div className="h-64 flex items-center justify-center">
              {chartData.length > 0 ? (
                renderSVGChart()
              ) : (
                <span className="text-xs text-slate-500">Generating chart data...</span>
              )}
            </div>
          </div>

          {/* Right: Tabbed Subscribers & Support Messages Table */}
          <div className="lg:col-span-5 glass p-6 rounded-2xl border border-slate-200 bg-white shadow-2xs flex flex-col gap-6 text-left">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex gap-4">
                <button
                  onClick={() => setActiveTab('subscribers')}
                  className={`text-sm font-extrabold pb-1.5 transition-colors relative cursor-pointer ${
                    activeTab === 'subscribers' ? 'text-slate-900' : 'text-slate-400 hover:text-slate-600'
                  }`}
                >
                  Subscribers ({subscribers.length})
                  {activeTab === 'subscribers' && (
                    <motion.div layoutId="activeTabUnderline" className="absolute bottom-0 left-0 right-0 h-0.5 bg-sky-500" />
                  )}
                </button>
                <button
                  onClick={() => setActiveTab('support')}
                  className={`text-sm font-extrabold pb-1.5 transition-colors relative cursor-pointer ${
                    activeTab === 'support' ? 'text-slate-900' : 'text-slate-400 hover:text-slate-600'
                  }`}
                >
                  Support Inbox ({supportMessages.length})
                  {activeTab === 'support' && (
                    <motion.div layoutId="activeTabUnderline" className="absolute bottom-0 left-0 right-0 h-0.5 bg-sky-500" />
                  )}
                </button>
              </div>
              <div className="p-1.5 rounded-lg bg-slate-50 border border-slate-100 text-sky-500">
                {activeTab === 'subscribers' ? <Mail className="w-4 h-4" /> : <MessageSquare className="w-4 h-4" />}
              </div>
            </div>

            {/* List */}
            <div className="flex-grow overflow-y-auto max-h-[300px] pr-1 space-y-3.5 no-scrollbar">
              {activeTab === 'subscribers' ? (
                subscribers.length > 0 ? (
                  subscribers.map((sub, idx) => (
                    <div 
                      key={sub.id || idx} 
                      className="p-3 rounded-xl bg-slate-50 border border-slate-200/50 flex items-center justify-between hover:border-slate-300 transition-colors"
                    >
                      <div className="space-y-0.5">
                        <p className="text-xs font-bold text-slate-800">{sub.name}</p>
                        <p className="text-[10px] text-slate-500 font-mono font-bold">{sub.email}</p>
                      </div>
                      <span className="text-[9px] text-slate-500 font-semibold uppercase">
                        {new Date(sub.timestamp).toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                      </span>
                    </div>
                  ))
                ) : (
                  <div className="h-full flex items-center justify-center py-12">
                    <span className="text-xs text-slate-500">No subscribers registered yet.</span>
                  </div>
                )
              ) : (
                supportMessages.length > 0 ? (
                  supportMessages.map((msg, idx) => (
                    <div 
                      key={msg.id || idx} 
                      className="p-3.5 rounded-xl bg-slate-50 border border-slate-200/50 flex flex-col gap-2 hover:border-slate-300 transition-colors text-left"
                    >
                      <div className="flex items-start justify-between gap-2">
                        <div className="space-y-0.5">
                          <p className="text-xs font-bold text-slate-800">{msg.name}</p>
                          <p className="text-[10px] text-slate-500 font-mono font-bold">{msg.email}</p>
                        </div>
                        <span className="text-[9px] text-slate-400 font-semibold shrink-0 uppercase">
                          {new Date(msg.timestamp).toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                        </span>
                      </div>
                      <p className="text-xs text-slate-650 bg-white p-2.5 rounded-lg border border-slate-150 leading-relaxed break-words font-medium">
                        {msg.message}
                      </p>
                      <a 
                        href={`mailto:${msg.email}?subject=Re:%20ClassSync%20Support`} 
                        className="text-[10px] text-sky-650 hover:text-sky-850 font-bold hover:underline self-end"
                      >
                        Reply via Email
                      </a>
                    </div>
                  ))
                ) : (
                  <div className="h-full flex items-center justify-center py-12">
                    <span className="text-xs text-slate-500">No support messages received yet.</span>
                  </div>
                )
              )}
            </div>
          </div>

        </div>

      </main>
    </div>
  );
}
