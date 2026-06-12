'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Calendar, LayoutDashboard, Percent, User, ArrowRight, ArrowLeft, Star, Volume2, Share2, BellRing, Check, ShieldAlert } from 'lucide-react';

type ScreenType = 'dashboard' | 'timetable' | 'attendance' | 'profile';

export default function ShowcaseSection() {
  const [activeScreen, setActiveScreen] = useState<ScreenType>('dashboard');
  const [attendanceMath, setAttendanceMath] = useState(82.4);
  const [attendanceNetworks, setAttendanceNetworks] = useState(68.5);

  const screens: { id: ScreenType; label: string; icon: any }[] = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'timetable', label: 'Timetable Grid', icon: Calendar },
    { id: 'attendance', label: 'Attendance', icon: Percent },
    { id: 'profile', label: 'Profile Share', icon: User },
  ];

  // Auto-play interval to cycle screens, but pause when user interacts
  const [isPaused, setIsPaused] = useState(false);

  useEffect(() => {
    if (isPaused) return;
    const interval = setInterval(() => {
      setActiveScreen((prev) => {
        if (prev === 'dashboard') return 'timetable';
        if (prev === 'timetable') return 'attendance';
        if (prev === 'attendance') return 'profile';
        return 'dashboard';
      });
    }, 8000);
    return () => clearInterval(interval);
  }, [isPaused]);

  const handleScreenChange = (screenId: ScreenType) => {
    setIsPaused(true);
    setActiveScreen(screenId);
  };

  const handleAttendanceChange = (subject: 'math' | 'networks', increment: boolean) => {
    if (subject === 'math') {
      setAttendanceMath(prev => Math.min(Math.max(Number((prev + (increment ? 2.5 : -2.5)).toFixed(1)), 0), 100));
    } else {
      setAttendanceNetworks(prev => Math.min(Math.max(Number((prev + (increment ? 2.5 : -2.5)).toFixed(1)), 0), 100));
    }
  };

  return (
    <section id="showcase" className="relative py-24 bg-white overflow-hidden border-t border-slate-100">
      {/* Mesh Background */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-sky-500/5 blur-[120px] rounded-full pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-sky-50 border border-sky-200 text-sky-600 text-xs font-bold">
            <Star className="w-3.5 h-3.5 fill-sky-400/20" /> Design Showcase
          </span>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
            Explore The ClassSync App Interface
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            Interact with our simulated app screen to see how easily you can navigate schedules and attendance tracking.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Screen Selector Tabs */}
          <div className="lg:col-span-5 flex flex-col gap-4 text-left order-2 lg:order-1">
            {screens.map((scr) => {
              const Icon = scr.icon;
              const isActive = activeScreen === scr.id;
              
              return (
                <button
                  key={scr.id}
                  onClick={() => handleScreenChange(scr.id)}
                  className={`w-full p-5 rounded-2xl border text-left flex items-start gap-4 transition-all duration-300 relative overflow-hidden group cursor-pointer ${
                    isActive 
                      ? 'bg-slate-50 border-sky-500/35 shadow-md shadow-sky-500/2' 
                      : 'bg-white border-slate-200/70 hover:border-slate-300 hover:bg-slate-50/30'
                  }`}
                >
                  {isActive && (
                    <motion.div 
                      layoutId="active-indicator" 
                      className="absolute inset-0 bg-gradient-to-r from-blue-900/5 via-sky-500/5 to-transparent z-0"
                    />
                  )}
                  
                  <div className={`p-2.5 rounded-xl border z-10 transition-colors duration-300 ${
                    isActive 
                      ? 'bg-sky-500/10 border-sky-500/20 text-sky-600' 
                      : 'bg-slate-50 border-slate-200 text-slate-500 group-hover:text-slate-700'
                  }`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  
                  <div className="space-y-1 z-10">
                    <h3 className={`font-bold transition-colors duration-300 ${isActive ? 'text-slate-900' : 'text-slate-700 group-hover:text-slate-900'}`}>
                      {scr.label}
                    </h3>
                    <p className="text-xs text-slate-500 leading-relaxed font-medium">
                      {scr.id === 'dashboard' && 'See what is running, what is next, and a breakdown of daily completed slots.'}
                      {scr.id === 'timetable' && 'Browse a fully color-coded weekly class grid with easy inline schedule editing.'}
                      {scr.id === 'attendance' && 'Track attendance subject-wise with visual thresholds. Click the test buttons to try.'}
                      {scr.id === 'profile' && 'Generate a sharing code for friends or backups, and manage local preferences.'}
                    </p>
                  </div>
                </button>
              );
            })}
          </div>

          {/* Right Column: HTML Device Mockup Container */}
          <div className="lg:col-span-7 flex justify-center order-1 lg:order-2">
            <div className="relative">
              {/* Outer Glow */}
              <div className="absolute inset-0 bg-sky-500/5 blur-[60px] rounded-[50px] z-0 animate-pulse"></div>

              {/* iPhone Mockup Frame */}
              <div className="phone-mockup w-[341px] h-[693px] rounded-[48px] bg-white border-[9px] border-slate-950 shadow-2xl relative z-10 overflow-hidden flex flex-col select-none ring-1 ring-slate-950/20">
                
                {/* Dynamic Island / Speaker Notch */}
                <div className="absolute top-2.5 left-1/2 -translate-x-1/2 w-28 h-6.5 rounded-full bg-slate-950 z-30 flex items-center justify-between px-3">
                  <div className="w-2.5 h-2.5 rounded-full bg-slate-900"></div>
                  <div className="w-1.5 h-1.5 rounded-full bg-sky-500 animate-pulse"></div>
                </div>

                {/* Status Bar */}
                <div className="h-10 pt-2 px-6 flex justify-between items-center text-[10px] text-slate-600 z-20 font-semibold font-sans select-none">
                  <span>9:41</span>
                  <div className="flex items-center gap-1.5">
                    <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61L4.35 19.4c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l1.9-1.9C9.13 19.58 10.53 20 12 20c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 15c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/>
                    </svg>
                    <span>LTE</span>
                    <div className="w-5 h-2.5 border border-slate-400 rounded-sm p-0.5 flex">
                      <div className="h-full w-4 bg-slate-500 rounded-2xs"></div>
                    </div>
                  </div>
                </div>

                {/* Screen Content Wrapper */}
                <div className="phone-screen flex-1 bg-white p-4 pt-1 flex flex-col justify-start overflow-hidden relative font-sans text-left">
                  <AnimatePresence mode="wait">
                    
                    {/* 1. DASHBOARD SCREEN */}
                    {activeScreen === 'dashboard' && (
                      <motion.div
                        key="dashboard"
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -20 }}
                        transition={{ duration: 0.3 }}
                        className="flex-1 flex flex-col gap-4 text-slate-800"
                      >
                        {/* App Header */}
                        <div className="flex justify-between items-center mt-1">
                          <div>
                            <span className="text-[10px] text-slate-500 uppercase tracking-widest block font-bold">Good morning</span>
                            <span className="text-base font-extrabold text-slate-900">Hey, Dhruva!</span>
                          </div>
                          <div className="w-8 h-8 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-700 hover:text-sky-500 shadow-2xs">
                            <BellRing className="w-4 h-4 text-sky-500" />
                          </div>
                        </div>

                        {/* Seeded Community Banner */}
                        <div className="p-3.5 rounded-2xl bg-gradient-to-r from-blue-900/10 to-sky-500/10 border border-sky-100 flex items-center justify-between shadow-inner">
                          <div>
                            <p className="text-[10px] uppercase font-bold text-sky-600 tracking-wider">Sync Active</p>
                            <p className="text-xs font-bold text-slate-800 mt-0.5">REVA Univ · CSE · Sem 4</p>
                          </div>
                          <span className="text-[9px] px-2 py-0.5 bg-emerald-100 text-emerald-700 border border-emerald-200 rounded font-bold">Sec A</span>
                        </div>

                        {/* Live Block: Now Running */}
                        <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/70 flex flex-col gap-3.5 relative overflow-hidden shadow-2xs">
                          {/* Top Tag */}
                          <div className="flex justify-between items-center">
                            <span className="text-[9px] uppercase font-bold text-sky-600 tracking-wider flex items-center gap-1">
                              <span className="w-1.5 h-1.5 rounded-full bg-sky-500 animate-ping"></span>
                              Now Running
                            </span>
                            <span className="text-[10px] text-slate-500 font-bold uppercase">Period 2</span>
                          </div>
                          {/* Subject */}
                          <div>
                            <h4 className="text-sm font-extrabold text-slate-900 leading-tight">Software Engineering</h4>
                            <p className="text-[10px] text-slate-500 mt-0.5 font-medium">Room 304 · Dr. Sarah Connor</p>
                          </div>
                          {/* Timing Progress */}
                          <div className="space-y-1">
                            <div className="flex justify-between text-[10px] font-mono text-slate-500">
                              <span>9:30 AM - 10:20 AM</span>
                              <span>65% Done</span>
                            </div>
                            <div className="w-full h-1.5 bg-slate-200 rounded-full overflow-hidden">
                              <div className="h-full w-[65%] bg-sky-500 rounded-full"></div>
                            </div>
                          </div>
                        </div>

                        {/* Next Classes Stack */}
                        <div className="flex-1 flex flex-col gap-2.5">
                          <h4 className="text-[10px] uppercase font-bold tracking-widest text-slate-500 pl-1">Upcoming Lectures</h4>
                          
                          {/* Card 1 */}
                          <div className="p-3 rounded-xl bg-slate-50/70 border border-slate-200/50 flex items-center justify-between hover:bg-slate-50 transition-colors">
                            <div className="flex items-center gap-3">
                              <div className="w-2.5 h-2.5 rounded-full bg-indigo-500"></div>
                              <div>
                                <h5 className="text-xs font-bold text-slate-800">Computer Networks</h5>
                                <p className="text-[9px] text-slate-500 font-medium">10:30 AM · Lab 3</p>
                              </div>
                            </div>
                            <span className="text-[10px] text-slate-500 font-bold">10 min gap</span>
                          </div>

                          {/* Card 2 */}
                          <div className="p-3 rounded-xl bg-slate-50/70 border border-slate-200/50 flex items-center justify-between hover:bg-slate-50 transition-colors">
                            <div className="flex items-center gap-3">
                              <div className="w-2.5 h-2.5 rounded-full bg-amber-500"></div>
                              <div>
                                <h5 className="text-xs font-bold text-slate-800">Tea Break</h5>
                                <p className="text-[9px] text-slate-500 font-medium">11:20 AM · Cafeteria</p>
                              </div>
                            </div>
                            <span className="text-[10px] text-amber-600 font-bold">15 min</span>
                          </div>

                          {/* Card 3 */}
                          <div className="p-3 rounded-xl bg-slate-50/70 border border-slate-200/50 flex items-center justify-between hover:bg-slate-50 transition-colors">
                            <div className="flex items-center gap-3">
                              <div className="w-2.5 h-2.5 rounded-full bg-teal-500"></div>
                              <div>
                                <h5 className="text-xs font-bold text-slate-800">Operating Systems</h5>
                                <p className="text-[9px] text-slate-500 font-medium">11:35 AM · Room 102</p>
                              </div>
                            </div>
                            <span className="text-[10px] text-slate-500 font-bold">50 min</span>
                          </div>
                        </div>

                      </motion.div>
                    )}

                    {/* 2. TIMETABLE GRID SCREEN */}
                    {activeScreen === 'timetable' && (
                      <motion.div
                        key="timetable"
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -20 }}
                        transition={{ duration: 0.3 }}
                        className="flex-1 flex flex-col gap-4 text-slate-800"
                      >
                        {/* Day Selector Navigation */}
                        <div className="flex justify-between items-center mt-1">
                          <h4 className="text-sm font-extrabold text-slate-900">Weekly Grid</h4>
                          <span className="text-[10px] uppercase font-bold text-sky-600">Monday</span>
                        </div>

                        {/* Day Badges */}
                        <div className="grid grid-cols-6 gap-1 border-b border-slate-100 pb-2">
                          {['M', 'T', 'W', 'T', 'F', 'S'].map((day, i) => (
                            <span 
                              key={i} 
                              className={`py-1 text-center text-[10px] font-bold rounded cursor-pointer ${
                                i === 0 ? 'bg-sky-500 text-white shadow-2xs' : 'bg-slate-50 text-slate-500 border border-slate-200/60'
                              }`}
                            >
                              {day}
                            </span>
                          ))}
                        </div>

                        {/* Timetable sequential slots */}
                        <div className="flex-1 flex flex-col gap-3 overflow-y-auto pr-0.5 no-scrollbar">
                          
                          {/* Slot 1 */}
                          <div className="p-3.5 rounded-xl border border-slate-200 border-l-4 border-l-sky-500 bg-slate-50/60 flex flex-col gap-2 shadow-2xs">
                            <div className="flex justify-between items-center">
                              <span className="text-[9px] font-bold uppercase tracking-wider text-sky-600">08:30 - 09:20</span>
                              <span className="text-[9px] text-slate-500 font-bold">Period 1</span>
                            </div>
                            <div className="flex justify-between items-start">
                              <div>
                                <h5 className="text-xs font-extrabold text-slate-900">Engineering Mathematics</h5>
                                <p className="text-[9px] text-slate-500 mt-0.5 font-medium">Room 201 · Prof. Ram</p>
                              </div>
                            </div>
                          </div>

                          {/* Slot 2 */}
                          <div className="p-3.5 rounded-xl border border-slate-200 border-l-4 border-l-indigo-500 bg-slate-50/60 flex flex-col gap-2 shadow-2xs">
                            <div className="flex justify-between items-center">
                              <span className="text-[9px] font-bold uppercase tracking-wider text-indigo-500">09:30 - 10:20</span>
                              <span className="text-[9px] text-slate-500 font-bold">Period 2</span>
                            </div>
                            <div className="flex justify-between items-start">
                              <div>
                                <h5 className="text-xs font-extrabold text-slate-900">Software Engineering</h5>
                                <p className="text-[9px] text-slate-500 mt-0.5 font-medium">Room 304 · Dr. Sarah</p>
                              </div>
                            </div>
                          </div>

                          {/* Slot 3 */}
                          <div className="p-3.5 rounded-xl border border-slate-200 border-l-4 border-l-teal-500 bg-slate-50/60 flex flex-col gap-2 shadow-2xs">
                            <div className="flex justify-between items-center">
                              <span className="text-[9px] font-bold uppercase tracking-wider text-teal-500">10:30 - 11:20</span>
                              <span className="text-[9px] text-slate-500 font-bold">Period 3</span>
                            </div>
                            <div className="flex justify-between items-start">
                              <div>
                                <h5 className="text-xs font-extrabold text-slate-900">Computer Networks</h5>
                                <p className="text-[9px] text-slate-500 mt-0.5 font-medium">Lab 3 · Prof. Dave</p>
                              </div>
                            </div>
                          </div>

                          {/* Quick Add Button */}
                          <button className="py-2.5 rounded-xl border border-dashed border-slate-200 text-slate-500 hover:text-sky-600 hover:border-sky-500/30 transition-all text-xs font-semibold flex items-center justify-center gap-1 bg-slate-50/30 mt-1 cursor-pointer">
                            + Add class slot
                          </button>
                        </div>
                      </motion.div>
                    )}

                    {/* 3. ATTENDANCE SCREEN */}
                    {activeScreen === 'attendance' && (
                      <motion.div
                        key="attendance"
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -20 }}
                        transition={{ duration: 0.3 }}
                        className="flex-1 flex flex-col gap-4 text-slate-800"
                      >
                        <div className="flex justify-between items-center mt-1">
                          <h4 className="text-sm font-extrabold text-slate-900">Attendance Panel</h4>
                          <span className="text-[9px] font-bold uppercase text-emerald-600 flex items-center gap-1">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                            Safe Overall
                          </span>
                        </div>

                        {/* Circular ring indicator placeholder */}
                        <div className="p-3 rounded-2xl bg-slate-50 border border-slate-200 flex items-center justify-around gap-4 py-4 shadow-2xs">
                          <div className="flex flex-col items-center gap-1">
                            <span className="text-xl font-black text-slate-900 font-mono">
                              {((attendanceMath + attendanceNetworks + 91.2) / 3).toFixed(1)}%
                            </span>
                            <span className="text-[8px] uppercase font-bold text-slate-500 tracking-wider">Average Attendance</span>
                          </div>
                          <div className="text-xs text-slate-500 leading-relaxed max-w-[140px] font-medium">
                            Required threshold is <strong className="text-slate-700 font-extrabold">75.0%</strong>. Keep all subjects safe.
                          </div>
                        </div>

                        {/* Subject Trackers List */}
                        <div className="flex-1 flex flex-col gap-3.5 overflow-y-auto pr-0.5 no-scrollbar">
                          
                          {/* Subject 1 - Math */}
                          <div className="p-3.5 rounded-xl bg-slate-50/60 border border-slate-200 flex flex-col gap-2.5 shadow-2xs">
                            <div className="flex justify-between items-center">
                              <span className="text-xs font-bold text-slate-900">Engineering Math</span>
                              <span className={`text-xs font-bold font-mono ${attendanceMath >= 75 ? 'text-emerald-600' : 'text-rose-500'}`}>
                                {attendanceMath}%
                              </span>
                            </div>
                            {/* Interactive Micro buttons */}
                            <div className="flex justify-between items-center">
                              <span className="text-[8px] text-slate-500 uppercase font-bold tracking-wider">Simulate Click:</span>
                              <div className="flex items-center gap-2">
                                <button 
                                  onClick={() => handleAttendanceChange('math', false)}
                                  className="px-2 py-1 rounded bg-white border border-slate-200 hover:border-red-500/40 text-[9px] hover:text-red-500 transition-colors font-bold cursor-pointer"
                                >
                                  Absent
                                </button>
                                <button 
                                  onClick={() => handleAttendanceChange('math', true)}
                                  className="px-2 py-1 rounded bg-white border border-slate-200 hover:border-emerald-500/40 text-[9px] hover:text-emerald-600 transition-colors font-bold cursor-pointer"
                                >
                                  Present
                                </button>
                              </div>
                            </div>
                          </div>

                          {/* Subject 2 - Computer Networks */}
                          <div className="p-3.5 rounded-xl bg-slate-50/60 border border-slate-200 flex flex-col gap-2.5 shadow-2xs">
                            <div className="flex justify-between items-center">
                              <span className="text-xs font-bold text-slate-900">Computer Networks</span>
                              <span className={`text-xs font-bold font-mono flex items-center gap-1 ${attendanceNetworks >= 75 ? 'text-emerald-600' : 'text-rose-500'}`}>
                                {attendanceNetworks < 75 && <ShieldAlert className="w-3 h-3 animate-bounce" />}
                                {attendanceNetworks}%
                              </span>
                            </div>
                            {/* Interactive Micro buttons */}
                            <div className="flex justify-between items-center">
                              <span className="text-[8px] text-slate-500 uppercase font-bold tracking-wider">Simulate Click:</span>
                              <div className="flex items-center gap-2">
                                <button 
                                  onClick={() => handleAttendanceChange('networks', false)}
                                  className="px-2 py-1 rounded bg-white border border-slate-200 hover:border-red-500/40 text-[9px] hover:text-red-500 transition-colors font-bold cursor-pointer"
                                >
                                  Absent
                                </button>
                                <button 
                                  onClick={() => handleAttendanceChange('networks', true)}
                                  className="px-2 py-1 rounded bg-white border border-slate-200 hover:border-emerald-500/40 text-[9px] hover:text-emerald-600 transition-colors font-bold cursor-pointer"
                                >
                                  Present
                                </button>
                              </div>
                            </div>
                            {attendanceNetworks < 75 && (
                              <p className="text-[9px] text-rose-500 font-bold leading-normal border-t border-rose-500/10 pt-1.5">
                                Needs {Math.ceil((75 * 20 - 20 * attendanceNetworks) / (100 - 75))} consecutive classes present to reach 75%!
                              </p>
                            )}
                          </div>
                        </div>

                      </motion.div>
                    )}

                    {/* 4. PROFILE SCREEN */}
                    {activeScreen === 'profile' && (
                      <motion.div
                        key="profile"
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -20 }}
                        transition={{ duration: 0.3 }}
                        className="flex-1 flex flex-col gap-4 text-slate-800"
                      >
                        <div className="flex justify-between items-center mt-1">
                          <h4 className="text-sm font-extrabold text-slate-900">Student Profile</h4>
                          <Share2 className="w-4 h-4 text-sky-500" />
                        </div>

                        {/* Avatar */}
                        <div className="flex flex-col items-center gap-2 py-3 border-b border-slate-100">
                          <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-blue-900 to-sky-400 flex items-center justify-center text-white font-extrabold text-2xl shadow-lg shadow-blue-900/10">
                            D
                          </div>
                          <div className="text-center">
                            <h5 className="text-sm font-extrabold text-slate-900">Dhruva</h5>
                            <p className="text-[10px] text-slate-500 font-medium">Computer Science Engineering</p>
                          </div>
                        </div>

                        {/* Sharing Info */}
                        <div className="space-y-3">
                          <span className="text-[10px] uppercase font-bold tracking-widest text-slate-500 pl-1 block">Share Timetable</span>
                          
                          {/* Sync Code Card */}
                          <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between shadow-2xs">
                            <div>
                              <p className="text-[8px] uppercase font-bold text-sky-600 tracking-wider">Your Sync Code</p>
                              <p className="text-sm font-extrabold text-slate-800 mt-0.5 font-mono">REVA-CSE-S4A</p>
                            </div>
                            <button className="p-2 rounded-lg bg-white border border-slate-200 hover:border-sky-500/30 text-sky-500 flex items-center justify-center cursor-pointer active:scale-95">
                              <Check className="w-3.5 h-3.5" />
                            </button>
                          </div>

                          <p className="text-[10px] text-slate-500 leading-normal text-center max-w-[220px] mx-auto font-medium">
                            Friends can scan your QR code or paste this code in their ClassSync app to import your weekly schedule instantly.
                          </p>
                        </div>

                        {/* Preferences */}
                        <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 flex justify-between items-center mt-auto shadow-2xs">
                          <span className="text-xs text-slate-700 font-medium">Automatic local backups</span>
                          <span className="w-8 h-4 rounded-full bg-sky-500 relative flex items-center px-0.5">
                            <span className="w-3.5 h-3.5 rounded-full bg-white absolute right-0.5"></span>
                          </span>
                        </div>
                      </motion.div>
                    )}

                  </AnimatePresence>
                </div>

                {/* iPhone Home Indicator */}
                <div className="h-5 flex items-center justify-center pb-2 z-20 select-none">
                  <div className="w-32 h-1.5 rounded-full bg-slate-200"></div>
                </div>

              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
