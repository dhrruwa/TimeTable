'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Clock, AlertTriangle, ShieldAlert, FileText, Sparkles, MessageSquare, AlertOctagon, HelpCircle, ArrowRight } from 'lucide-react';

// Bento Micro-Graphics for student pain points

const PdfBlurGraphic = () => (
  <div className="w-full bg-slate-50 border border-slate-200/60 rounded-xl p-3.5 space-y-2.5 font-sans relative overflow-hidden pointer-events-none select-none">
    <div className="flex justify-between items-center text-[9px] text-slate-400 font-extrabold uppercase tracking-wider">
      <span>File: Timetable_v2_final.pdf</span>
      <span className="text-red-500 font-bold">Zoom 400%</span>
    </div>
    <div className="space-y-1.5 filter blur-[1.5px]">
      <div className="h-3 bg-slate-200 rounded w-full"></div>
      <div className="h-3 bg-slate-200 rounded w-[85%]"></div>
      <div className="h-3 bg-slate-200 rounded w-[90%]"></div>
    </div>
    <div className="absolute inset-0 flex items-center justify-center bg-white/10">
      <div className="w-8 h-8 rounded-full bg-red-100 flex items-center justify-center text-red-500 shadow-md border border-red-200">
        <HelpCircle className="w-4 h-4 animate-pulse" />
      </div>
    </div>
  </div>
);

const OverlapGraphic = () => (
  <div className="w-full bg-slate-50 border border-slate-200/60 rounded-xl p-3.5 space-y-2 font-sans relative overflow-hidden pointer-events-none select-none min-h-[90px] flex flex-col justify-center">
    <div className="relative h-12 w-full">
      <div className="absolute left-0 top-0 w-[60%] bg-rose-50 border border-rose-200 text-rose-700 rounded-lg p-1 text-[8px] font-bold z-10 shadow-3xs">
        Theory: Math Class
        <span className="block text-[7px] text-rose-500 font-medium">Room 102 · 10:00 AM</span>
      </div>
      <div className="absolute right-0 top-2 w-[60%] bg-amber-50 border border-amber-200 text-amber-700 rounded-lg p-1 text-[8px] font-bold z-20 shadow-3xs flex justify-between items-center">
        <div>
          Lab: Chemistry
          <span className="block text-[7px] text-amber-500 font-medium">Lab 3 · 10:00 AM</span>
        </div>
        <AlertTriangle className="w-3.5 h-3.5 text-amber-500 shrink-0" />
      </div>
    </div>
  </div>
);

const LowAttendanceGraphic = () => (
  <div className="w-full bg-slate-50 border border-slate-200/60 rounded-xl p-3.5 space-y-2.5 font-sans pointer-events-none select-none">
    <div className="flex justify-between items-center text-[9px] text-slate-400 font-extrabold uppercase tracking-wider">
      <span>Dashboard</span>
      <span className="px-1.5 py-0.5 bg-red-50 text-[7px] font-black text-red-600 border border-red-100 rounded">
        CRITICAL
      </span>
    </div>
    <div className="flex items-center gap-3">
      <div className="relative flex items-center justify-center shrink-0">
        <svg className="w-10 h-10 transform -rotate-90">
          <circle cx="20" cy="20" r="16" stroke="#e2e8f0" strokeWidth="3.5" fill="transparent" />
          <circle cx="20" cy="20" r="16" stroke="#ef4444" strokeWidth="3.5" fill="transparent" strokeDasharray="100" strokeDashoffset="35" />
        </svg>
        <span className="absolute text-[8px] font-black text-slate-700">65%</span>
      </div>
      <div className="text-left">
        <h5 className="text-[10px] font-black text-slate-800">Overall Attendance</h5>
        <p className="text-[8px] text-red-500 font-semibold mt-0.5">Need 5 consecutive classes to hit 75%</p>
      </div>
    </div>
  </div>
);

const ChatSearchGraphic = () => (
  <div className="w-full bg-slate-50 border border-slate-200/60 rounded-xl p-3.5 space-y-2 font-sans pointer-events-none select-none">
    <div className="flex justify-between items-center text-[9px] text-slate-400 font-extrabold uppercase tracking-wider">
      <span>Class WhatsApp Group</span>
      <span className="text-[8px] text-slate-400 font-mono">11:42 PM</span>
    </div>
    <div className="flex items-start gap-2 max-w-[85%] bg-white border border-slate-200 p-2 rounded-xl rounded-tl-none shadow-3xs">
      <div className="w-6 h-6 rounded-lg bg-red-50 border border-red-100 flex items-center justify-center text-red-500 shrink-0">
        <FileText className="w-3.5 h-3.5" />
      </div>
      <div className="text-left">
        <span className="text-[8px] text-sky-600 font-bold block">Class Rep</span>
        <span className="text-[9px] font-black text-slate-700 block mt-0.5">Timetable_v3_final_final.pdf</span>
        <span className="text-[8px] text-slate-400 block mt-0.5">Wait, this is the old one?</span>
      </div>
    </div>
  </div>
);

const timelineSteps = [
  {
    time: '08:30 AM',
    phase: 'Morning Rush',
    title: 'Which class is running?',
    description: 'You just walked into campus. Staring at a static timetable PDF in your photo gallery trying to figure out which slot matches the current time is a daily annoyance.',
    graphic: PdfBlurGraphic,
    iconColor: 'text-orange-500',
    bgColor: 'bg-orange-50/30 border-orange-100',
  },
  {
    time: '11:15 AM',
    phase: 'Shift Confusion',
    title: 'Timetable overlap confusion',
    description: 'You head to the lab, only to find it locked. Missing classes because slots shifted, or confusing a Tuesday timetable for a Thursday schedule.',
    graphic: OverlapGraphic,
    iconColor: 'text-red-500',
    bgColor: 'bg-red-50/30 border-red-100',
  },
  {
    time: '02:30 PM',
    phase: 'Skip Risk',
    title: 'Attendance blindspots',
    description: 'Can you skip this lecture to study for finals? You have no idea what your exact attendance percentage is until the warning letter arrives.',
    graphic: LowAttendanceGraphic,
    iconColor: 'text-pink-500',
    bgColor: 'bg-pink-50/30 border-pink-100',
  },
  {
    time: '04:45 PM',
    phase: 'Search Fatigue',
    title: 'No centralized system',
    description: 'Relying on group chat pins or outdated college portals that refuse to load on mobile browsers when you need tomorrow\'s schedule.',
    graphic: ChatSearchGraphic,
    iconColor: 'text-rose-500',
    bgColor: 'bg-rose-50/30 border-rose-100',
  },
];

export default function ProblemSection() {
  return (
    <section id="problem" className="relative py-24 overflow-hidden bg-white border-t border-slate-100">
      {/* Background soft blurs */}
      <div className="absolute top-1/4 left-0 w-80 h-80 rounded-full bg-red-150/10 blur-[100px] pointer-events-none"></div>
      <div className="absolute bottom-1/4 right-0 w-72 h-72 rounded-full bg-orange-150/10 blur-[120px] pointer-events-none"></div>

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-20 space-y-4">
          <h2 className="text-xs uppercase tracking-widest text-rose-600 font-bold flex items-center justify-center gap-1.5">
            <AlertOctagon className="w-3.5 h-3.5" /> The Struggle is Real
          </h2>
          <h3 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
            A Day in the Life of a Student
          </h3>
          <p className="text-slate-600 text-sm sm:text-base font-semibold">
            Being in college is busy enough. Struggling with a simple daily schedule shouldn't be part of the stress.
          </p>
        </div>

        {/* Timeline Stack */}
        <div className="relative border-l-2 border-slate-200 ml-4 sm:ml-6 md:ml-32 space-y-12 text-left">
          
          {timelineSteps.map((step, idx) => {
            const Graphic = step.graphic;
            return (
              <motion.div
                key={idx}
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true, margin: '-100px' }}
                transition={{ duration: 0.5, delay: idx * 0.1 }}
                className="relative pl-8 sm:pl-12 group"
              >
                {/* Timeline node clock icon */}
                <span className="absolute -left-[13px] top-0 flex items-center justify-center w-6 h-6 rounded-full bg-white border-2 border-slate-200 group-hover:border-sky-500 transition-colors z-10">
                  <Clock className="w-3 h-3 text-slate-400 group-hover:text-sky-500 transition-colors" />
                </span>

                {/* Left floating time indicator (on larger screens) */}
                <div className="hidden md:block absolute -left-[140px] top-0.5 text-right w-28 space-y-0.5">
                  <span className="text-xs font-black text-slate-800">{step.time}</span>
                  <span className="block text-[9px] uppercase tracking-wider text-slate-400 font-bold font-mono">{step.phase}</span>
                </div>

                {/* Main Card */}
                <div className={`rounded-2xl border ${step.bgColor} p-6 flex flex-col md:flex-row gap-6 items-center justify-between shadow-2xs hover:shadow-md transition-all duration-300`}>
                  <div className="space-y-2.5 flex-1">
                    {/* Time indicator for mobile */}
                    <div className="md:hidden flex items-baseline gap-2">
                      <span className="text-xs font-black text-slate-800">{step.time}</span>
                      <span className="text-[9px] uppercase tracking-wider text-slate-400 font-bold font-mono">· {step.phase}</span>
                    </div>
                    <h4 className="font-extrabold text-slate-800 text-lg leading-tight group-hover:text-slate-900 transition-colors">
                      {step.title}
                    </h4>
                    <p className="text-slate-500 text-xs sm:text-sm leading-relaxed font-semibold">
                      {step.description}
                    </p>
                  </div>
                  <div className="w-full md:w-[240px] shrink-0 bg-white p-1 rounded-xl">
                    <Graphic />
                  </div>
                </div>
              </motion.div>
            );
          })}

        </div>

        {/* Call to Action at the end of the timeline */}
        <div className="mt-16 flex justify-center">
          <motion.button
            whileHover={{ scale: 1.03 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => document.getElementById('solution')?.scrollIntoView({ behavior: 'smooth' })}
            className="inline-flex items-center gap-2 px-6 py-3.5 bg-sky-500 hover:bg-sky-600 text-white font-bold rounded-2xl shadow-md hover:shadow-lg transition-all cursor-pointer text-sm"
          >
            Ready for a Solution?
            <ArrowRight className="w-4 h-4" />
          </motion.button>
        </div>

      </div>
    </section>
  );
}
