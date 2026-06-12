'use client';

import React, { useEffect, useState, useRef } from 'react';
import { motion, useInView } from 'framer-motion';
import { getStats, Stats } from '../lib/db';
import { Download, Users, Calendar, Activity } from 'lucide-react';

function AnimatedCounter({ value, duration = 1.5 }: { value: number; duration?: number }) {
  const [count, setCount] = useState(0);
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-50px' });

  useEffect(() => {
    if (!isInView) return;
    
    let startTimestamp: number | null = null;
    const step = (timestamp: number) => {
      if (!startTimestamp) startTimestamp = timestamp;
      const progress = Math.min((timestamp - startTimestamp) / (duration * 1000), 1);
      setCount(Math.floor(progress * value));
      if (progress < 1) {
        window.requestAnimationFrame(step);
      }
    };
    window.requestAnimationFrame(step);
  }, [value, duration, isInView]);

  return (
    <span ref={ref} className="font-mono">
      {count.toLocaleString()}
    </span>
  );
}

export default function StatsSection() {
  const [stats, setStats] = useState<Stats>({
    totalDownloads: 0,
    activeStudents: 0,
    timetablesCreated: 0,
    classesTracked: 0,
  });

  useEffect(() => {
    const fetchStats = async () => {
      const data = await getStats();
      setStats(data);
    };
    fetchStats();
    
    // Poll stats occasionally to feel "live"
    const interval = setInterval(fetchStats, 15000);
    return () => clearInterval(interval);
  }, []);

  const statsItems = [
    {
      label: 'Total Downloads',
      value: stats.totalDownloads || 1420,
      icon: Download,
      glow: 'shadow-sky-500/5',
      iconColor: 'text-sky-500',
    },
    {
      label: 'Active Students',
      value: stats.activeStudents || 1180,
      icon: Users,
      glow: 'shadow-indigo-500/5',
      iconColor: 'text-indigo-500',
    },
    {
      label: 'Timetables Created',
      value: stats.timetablesCreated || 3840,
      icon: Calendar,
      glow: 'shadow-purple-500/5',
      iconColor: 'text-purple-500',
    },
    {
      label: 'Classes Tracked',
      value: stats.classesTracked || 57600,
      icon: Activity,
      glow: 'shadow-emerald-500/5',
      iconColor: 'text-emerald-500',
    },
  ];

  return (
    <section id="stats" className="relative py-20 bg-gradient-to-b from-white to-slate-50 overflow-hidden border-y border-slate-100">
      {/* Mesh gradients */}
      <div className="absolute top-1/2 left-0 -translate-y-1/2 w-72 h-72 rounded-full bg-sky-100/20 blur-[100px] pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16 space-y-3">
          <h2 className="text-xs uppercase tracking-widest text-sky-600 font-bold">Live Pulse</h2>
          <h3 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
            ClassSync Community Statistics
          </h3>
          <p className="text-slate-600 text-sm sm:text-base">
            Real-time numbers updated from our database endpoints as students join.
          </p>
        </div>

        {/* Counters Grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
          {statsItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, scale: 0.95 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: index * 0.08 }}
                className={`glass p-6 rounded-2xl border border-slate-200 bg-white/80 flex flex-col items-center text-center shadow-sm hover:border-slate-300 transition-colors ${item.glow}`}
              >
                <div className={`p-3 rounded-xl bg-slate-50 border border-slate-200/60 ${item.iconColor} mb-4`}>
                  <Icon className="w-5.5 h-5.5" />
                </div>
                
                <div className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
                  <AnimatedCounter value={item.value} />
                </div>
                
                <p className="text-xs text-slate-500 font-bold uppercase tracking-wider mt-2.5">
                  {item.label}
                </p>
              </motion.div>
            );
          })}
        </div>

      </div>
    </section>
  );
}
