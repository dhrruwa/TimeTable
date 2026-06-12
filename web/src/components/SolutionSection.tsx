'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { CheckCircle2, LayoutDashboard, Compass, Layers, ShieldCheck, Activity } from 'lucide-react';

const solutions = [
  { label: 'Current Period', desc: 'Instantly view which class is running and where.' },
  { label: 'Next Period', desc: 'Countdown and locations for what is coming up next.' },
  { label: 'Remaining Classes', desc: 'See how many lectures are left in the day.' },
  { label: 'Attendance Percentage', desc: 'Visual markers showing safe, warning, and low levels.' },
  { label: 'Daily Progress', desc: 'A progress bar indicating completed classes.' },
];

export default function SolutionSection() {
  return (
    <section id="solution" className="relative py-24 bg-gradient-to-b from-white to-slate-50 overflow-hidden border-t border-slate-100">
      {/* Background glow overlay */}
      <div className="absolute right-0 top-1/4 w-96 h-96 bg-sky-100/30 rounded-full blur-[120px] pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-16 items-center">
          
          {/* Left Side: Information */}
          <div className="lg:col-span-6 space-y-8 text-left">
            <div className="space-y-4">
              <h2 className="text-xs uppercase tracking-widest text-sky-600 font-bold flex items-center gap-1.5">
                <Compass className="w-3.5 h-3.5 animate-spin-slow" /> Smart Integration
              </h2>
              <h3 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
                Built By Students, For Students
              </h3>
              <p className="text-slate-600 text-base sm:text-lg leading-relaxed font-light">
                As engineering students, we got tired of hunting down timing details and room numbers. This application automatically tracks your timetable and helps you instantly know everything at a single glance.
              </p>
            </div>

            {/* Checklist */}
            <div className="space-y-4">
              {solutions.map((sol, index) => (
                <motion.div 
                  key={index}
                  initial={{ opacity: 0, x: -20 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: index * 0.08 }}
                  className="flex items-start gap-3.5"
                >
                  <div className="w-6 h-6 rounded-full bg-sky-50 border border-sky-200 flex items-center justify-center text-sky-500 mt-0.5 shrink-0 shadow-inner">
                    <CheckCircle2 className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-800">{sol.label}</h4>
                    <p className="text-xs text-slate-500 mt-0.5">{sol.desc}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Right Side: Miniature App Dashboard Graphic */}
          <div className="lg:col-span-6 relative flex justify-center">
            {/* Ambient glows */}
            <div className="absolute w-80 h-80 bg-indigo-500/5 blur-[80px] rounded-full top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"></div>
            
            <motion.div 
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
              className="glass w-full max-w-md p-6 rounded-3xl border border-slate-200 shadow-xl relative z-10 flex flex-col gap-5 bg-white/80"
            >
              <div className="flex justify-between items-center pb-4 border-b border-slate-100">
                <span className="text-sm font-bold text-slate-800 flex items-center gap-1.5">
                  <LayoutDashboard className="w-4 h-4 text-sky-500" />
                  Live Sync Panel
                </span>
                <span className="text-[10px] uppercase font-mono bg-sky-50 border border-sky-200 text-sky-600 px-2 py-0.5 rounded-full font-bold">
                  Synchronized
                </span>
              </div>

              {/* Grid elements representing mock features */}
              <div className="grid grid-cols-2 gap-4">
                
                {/* Now Widget */}
                <div className="p-4 rounded-2xl bg-white border border-slate-200/70 shadow-2xs">
                  <div className="flex justify-between text-[10px] text-slate-500 font-bold uppercase tracking-wider">
                    <span>Now Running</span>
                    <Activity className="w-3.5 h-3.5 text-rose-500" />
                  </div>
                  <p className="text-sm font-extrabold text-slate-800 mt-3">Computer Networks</p>
                  <p className="text-[10px] text-slate-500 mt-0.5 font-medium">Lab 3 · 40m left</p>
                </div>

                {/* Next Widget */}
                <div className="p-4 rounded-2xl bg-white border border-slate-200/70 shadow-2xs">
                  <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider block">Next Lecture</span>
                  <p className="text-sm font-extrabold text-slate-800 mt-3">Operating Systems</p>
                  <p className="text-[10px] text-slate-500 mt-0.5 font-medium">Room 102 · 11:30 AM</p>
                </div>

                {/* Progress Ring Card */}
                <div className="p-4 rounded-2xl bg-white border border-slate-200/70 shadow-2xs flex flex-col justify-between">
                  <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider block">Day Progress</span>
                  <div className="mt-3 flex items-end justify-between">
                    <span className="text-2xl font-bold text-slate-800 font-mono">60%</span>
                    <span className="text-[10px] text-sky-600 font-bold">3/5 slots</span>
                  </div>
                  <div className="w-full h-1 bg-slate-100 rounded-full mt-2 overflow-hidden border border-slate-200/50">
                    <div className="w-3/5 h-full bg-sky-500 rounded-full"></div>
                  </div>
                </div>

                {/* Attendance Score Card */}
                <div className="p-4 rounded-2xl bg-white border border-slate-200/70 shadow-2xs flex flex-col justify-between">
                  <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider block">Overall Status</span>
                  <div className="mt-3 flex items-end justify-between">
                    <span className="text-2xl font-bold text-emerald-600 font-mono">81.2%</span>
                    <ShieldCheck className="w-4 h-4 text-emerald-500" />
                  </div>
                  <span className="text-[9px] text-slate-500 mt-1 block font-medium">8.5% above minimum limit</span>
                </div>

              </div>

              {/* Bottom Schedule Card */}
              <div className="p-3.5 rounded-2xl bg-gradient-to-r from-blue-900/5 to-sky-500/10 border border-blue-900/10 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <div className="w-2.5 h-2.5 rounded-full bg-sky-500 animate-pulse"></div>
                  <div>
                    <p className="text-xs font-bold text-slate-800">System Notification</p>
                    <p className="text-[10px] text-slate-500 font-medium">Class starting in 10 minutes</p>
                  </div>
                </div>
                <span className="text-[9px] font-mono text-slate-400 font-bold">Just Now</span>
              </div>

            </motion.div>
          </div>

        </div>
      </div>
    </section>
  );
}
