'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { ArrowRight, Database, Cloud, Bell, Clock, Percent, ShieldCheck } from 'lucide-react';

// Bento Micro-Graphics

const TimetablePreview = () => {
  const schedule = [
    { day: 'Mon', classes: [{ sub: 'MAT', color: 'bg-sky-500/10 text-sky-600 border-sky-200' }, { sub: 'CSE', color: 'bg-indigo-500/10 text-indigo-600 border-indigo-200' }] },
    { day: 'Tue', classes: [{ sub: 'ECE', color: 'bg-emerald-500/10 text-emerald-600 border-emerald-200' }, { sub: 'MAT', color: 'bg-sky-500/10 text-sky-600 border-sky-200' }] },
    { day: 'Wed', classes: [{ sub: 'CSE', color: 'bg-indigo-500/10 text-indigo-600 border-indigo-200' }, { sub: 'ECE', color: 'bg-emerald-500/10 text-emerald-600 border-emerald-200' }] },
    { day: 'Thu', classes: [{ sub: 'LAB', color: 'bg-purple-500/10 text-purple-600 border-purple-200' }, { sub: 'CSE', color: 'bg-indigo-500/10 text-indigo-600 border-indigo-200' }] },
    { day: 'Fri', classes: [{ sub: 'MAT', color: 'bg-sky-500/10 text-sky-600 border-sky-200' }, { sub: 'LAB', color: 'bg-purple-500/10 text-purple-600 border-purple-200' }] }
  ];
  return (
    <div className="w-full bg-slate-50 border border-slate-200/60 rounded-xl p-3.5 space-y-2.5 font-sans pointer-events-none select-none">
      <div className="flex justify-between items-center text-[10px] text-slate-400 font-extrabold uppercase tracking-wider">
        <span>Weekly Grid</span>
        <span className="text-sky-600">Sem 4 (CSE-A)</span>
      </div>
      <div className="grid grid-cols-5 gap-2">
        {schedule.map((item, idx) => (
          <div key={idx} className="space-y-2 text-center">
            <span className="text-[10px] font-bold text-slate-400 block">{item.day}</span>
            {item.classes.map((c, i) => (
              <div key={i} className={`text-[9px] font-black py-1 px-1.5 border rounded-lg ${c.color} truncate shadow-3xs`}>
                {c.sub}
              </div>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
};

const WidgetPreview = () => {
  return (
    <div className="w-full bg-slate-50 border border-slate-200/60 rounded-2xl p-3.5 space-y-3 font-sans relative overflow-hidden pointer-events-none select-none shadow-xs">
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping"></div>
          <span className="text-[9px] font-extrabold text-slate-400 uppercase tracking-widest">Active Widget</span>
        </div>
        <span className="text-[8px] font-mono text-slate-400 font-bold">ClassSync Widget</span>
      </div>
      
      <div className="space-y-1">
        <span className="text-[9px] text-slate-400 font-bold uppercase tracking-wider block">Ongoing Period</span>
        <h5 className="text-xs font-black text-slate-800 leading-tight">Advanced CSE Seminar</h5>
        <div className="flex justify-between items-center text-[9px] text-slate-500 font-bold mt-1">
          <span>Room 402B</span>
          <span>15 mins left</span>
        </div>
      </div>
      
      <div className="w-full bg-slate-200/80 rounded-full h-1.5 overflow-hidden">
        <div className="bg-sky-500 h-1.5 rounded-full w-[65%]"></div>
      </div>
    </div>
  );
};

const NotificationPreview = () => {
  return (
    <div className="w-full bg-white border border-slate-200/80 rounded-2xl p-3.5 shadow-sm flex gap-3 pointer-events-none select-none max-w-sm mx-auto relative overflow-hidden">
      <div className="w-9 h-9 rounded-xl bg-sky-50 flex items-center justify-center text-sky-600 shrink-0 border border-sky-100">
        <Bell className="w-4 h-4 text-sky-500" />
      </div>
      <div className="space-y-0.5 text-left">
        <div className="flex items-baseline justify-between">
          <h5 className="text-xs font-black text-slate-800">ClassSync Reminders</h5>
          <span className="text-[8px] text-slate-400 font-bold font-mono">now</span>
        </div>
        <p className="text-[10px] font-black text-slate-700 leading-tight">Class starting in 5 minutes!</p>
        <p className="text-[9px] text-slate-500 font-medium">Room 402B · Advanced CSE Seminar is starting soon.</p>
      </div>
    </div>
  );
};

const BackupPreview = () => {
  return (
    <div className="w-full bg-slate-50 border border-slate-200/60 rounded-xl p-3.5 flex items-center justify-around font-sans relative overflow-hidden pointer-events-none select-none h-[115px]">
      <div className="flex flex-col items-center gap-1.5">
        <div className="w-10 h-10 rounded-xl bg-sky-50 border border-sky-100 flex items-center justify-center text-sky-500 shadow-2xs">
          <Database className="w-5 h-5" />
        </div>
        <span className="text-[9px] font-extrabold text-slate-500 uppercase tracking-widest">Local Database</span>
      </div>
      
      {/* Dynamic flowing connection line */}
      <div className="flex-1 max-w-[100px] h-0.5 bg-slate-200 relative">
        <motion.div 
          className="absolute top-[-2px] w-2 h-2 rounded-full bg-sky-500"
          animate={{ left: ['0%', '100%'] }}
          transition={{ repeat: Infinity, duration: 2.5, ease: "linear" }}
        />
        <motion.div 
          className="absolute top-[-2px] w-2 h-2 rounded-full bg-indigo-500"
          animate={{ left: ['0%', '100%'] }}
          transition={{ repeat: Infinity, duration: 2.5, ease: "linear", delay: 1.25 }}
        />
      </div>

      <div className="flex flex-col items-center gap-1.5">
        <div className="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-500 shadow-2xs">
          <Cloud className="w-5 h-5" />
        </div>
        <span className="text-[9px] font-extrabold text-slate-500 uppercase tracking-widest">Cloud Encrypted</span>
      </div>
    </div>
  );
};

export default function FeaturesSection() {
  const scrollToSection = (id: string) => {
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="features" className="relative py-16 bg-slate-50/50 overflow-hidden border-t border-slate-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-12">
        
        {/* Collections Header (Zomato Collections Style) */}
        <div className="space-y-8 text-left">
          
          {/* Header */}
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
            <div className="space-y-2">
              <h2 className="text-3xl font-extrabold text-slate-900 tracking-tight">Collections</h2>
              <p className="text-slate-600 text-sm font-semibold">
                Explore curated options, styles, and tools that enhance your schedule layouts.
              </p>
            </div>
            <button 
              onClick={() => scrollToSection('showcase')}
              className="text-xs text-sky-500 hover:text-sky-600 font-bold flex items-center gap-1 shrink-0 cursor-pointer"
            >
              All collections in ClassSync <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>

          {/* Collections list (Bento Grid Layout) */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            
            {/* Card 1: Trending Timetables (Large card - spans 2 columns) */}
            <motion.div
              whileHover={{ y: -4 }}
              onClick={() => scrollToSection('showcase')}
              className="md:col-span-2 rounded-2xl border border-slate-200/80 bg-white p-6 sm:p-8 flex flex-col md:flex-row gap-6 items-center justify-between shadow-2xs hover:shadow-md cursor-pointer transition-all duration-300 text-left"
            >
              <div className="space-y-3 flex-1">
                <span className="text-[10px] font-bold text-slate-500 bg-slate-100 border border-slate-200 px-2 py-0.5 rounded font-mono shadow-3xs">
                  12 active classes
                </span>
                <h4 className="font-extrabold text-slate-900 text-lg sm:text-xl">
                  Trending Timetables
                </h4>
                <p className="text-xs sm:text-sm text-slate-500 leading-relaxed font-semibold">
                  Most imported college branch schedules this week. Quickly sync with classmates.
                </p>
              </div>
              <div className="w-full md:w-[280px] shrink-0">
                <TimetablePreview />
              </div>
            </motion.div>

            {/* Card 2: Widget Kit Skins */}
            <motion.div
              whileHover={{ y: -4 }}
              onClick={() => scrollToSection('showcase')}
              className="md:col-span-1 rounded-2xl border border-slate-200/80 bg-white p-6 flex flex-col justify-between shadow-2xs hover:shadow-md cursor-pointer transition-all duration-300 text-left space-y-6"
            >
              <div className="space-y-3">
                <span className="text-[10px] font-bold text-slate-500 bg-slate-100 border border-slate-200 px-2 py-0.5 rounded font-mono shadow-3xs">
                  4 launcher skins
                </span>
                <h4 className="font-extrabold text-slate-900 text-lg">
                  Widget Kit Skins
                </h4>
                <p className="text-xs text-slate-500 leading-normal font-semibold">
                  Custom widget frames to overlay timetables directly on your home screen.
                </p>
              </div>
              <WidgetPreview />
            </motion.div>

            {/* Card 3: Smart Notifications */}
            <motion.div
              whileHover={{ y: -4 }}
              onClick={() => scrollToSection('showcase')}
              className="md:col-span-1 rounded-2xl border border-slate-200/80 bg-white p-6 flex flex-col justify-between shadow-2xs hover:shadow-md cursor-pointer transition-all duration-300 text-left space-y-6"
            >
              <div className="space-y-3">
                <span className="text-[10px] font-bold text-slate-500 bg-slate-100 border border-slate-200 px-2 py-0.5 rounded font-mono shadow-3xs">
                  3 alarm modules
                </span>
                <h4 className="font-extrabold text-slate-900 text-lg">
                  Smart Notifications
                </h4>
                <p className="text-xs text-slate-500 leading-normal font-semibold">
                  Intelligent alarms triggered minutes before a period starts. Never rush to classes.
                </p>
              </div>
              <NotificationPreview />
            </motion.div>

            {/* Card 4: Backup & Restore */}
            <motion.div
              whileHover={{ y: -4 }}
              onClick={() => scrollToSection('showcase')}
              className="md:col-span-2 rounded-2xl border border-slate-200/80 bg-white p-6 sm:p-8 flex flex-col md:flex-row gap-6 items-center justify-between shadow-2xs hover:shadow-md cursor-pointer transition-all duration-300 text-left"
            >
              <div className="space-y-3 flex-1">
                <span className="text-[10px] font-bold text-slate-500 bg-slate-100 border border-slate-200 px-2 py-0.5 rounded font-mono shadow-3xs">
                  Local & Cloud options
                </span>
                <h4 className="font-extrabold text-slate-900 text-lg sm:text-xl">
                  Backup & Restore
                </h4>
                <p className="text-xs sm:text-sm text-slate-500 leading-relaxed font-semibold">
                  Store schedules locally in Isar database or sync to encrypted cloud backups for data safety.
                </p>
              </div>
              <div className="w-full md:w-[280px] shrink-0">
                <BackupPreview />
              </div>
            </motion.div>

          </div>

        </div>

      </div>
    </section>
  );
}
