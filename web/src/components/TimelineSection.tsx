'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Lightbulb, Code2, Rocket, Milestone, Sparkles } from 'lucide-react';

const steps = [
  {
    icon: Lightbulb,
    title: 'The Daily Frustration',
    date: 'Early 2025',
    description: 'We were tired of guessing which class was next, checking messy group chats, or manually calculating attendance safety. Spreadsheet schedules and blurry PDF screenshots simply weren\'t enough.',
    glow: 'border-amber-200 bg-amber-50/10 shadow-amber-500/2',
    iconColor: 'text-amber-500',
  },
  {
    icon: Code2,
    title: 'Designing The Core Engine',
    date: 'Summer 2025',
    description: 'We sat down to design a smart scheduling calculator. The goal was simple: take repeating timetable slots and automatically calculate what\'s running now, what\'s coming up next, and the day\'s total completion percentage.',
    glow: 'border-indigo-200 bg-indigo-50/10 shadow-indigo-500/2',
    iconColor: 'text-indigo-500',
  },
  {
    icon: Milestone,
    title: 'Building the App',
    date: 'Fall 2025',
    description: 'We built a clean, intuitive, local-first app that runs entirely offline. We focused on instant responsiveness: color-coded days, adding new courses in under 15 seconds, and full support for light/dark themes.',
    glow: 'border-sky-200 bg-sky-50/10 shadow-sky-500/2',
    iconColor: 'text-sky-500',
  },
  {
    icon: Rocket,
    title: 'ClassSync Launch',
    date: 'June 2026',
    description: 'Today, ClassSync is available for early access. The app is fully interactive, pre-seeded with sample timetables, and ready to help you track your schedule and attendance effortlessly right from your phone.',
    glow: 'border-emerald-200 bg-emerald-50/10 shadow-emerald-500/2',
    iconColor: 'text-emerald-500',
  },
];

export default function TimelineSection() {
  return (
    <section id="story" className="relative py-24 bg-gradient-to-b from-slate-50 to-white overflow-hidden border-t border-slate-100">
      {/* Background glow highlights */}
      <div className="glow-dot top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-sky-500/5 w-[500px] h-[500px]"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-20 space-y-4">
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 border border-blue-200 text-blue-800 text-xs font-bold">
            <Sparkles className="w-3.5 h-3.5" /> Out of Necessity
          </span>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
            How The Idea Started
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            A simple story of engineering students solving their own daily schedules, from frustrating PDFs to automated tracking.
          </p>
        </div>

        {/* Timeline Path */}
        <div className="relative max-w-4xl mx-auto">
          {/* Vertical Line */}
          <div className="absolute left-4 md:left-1/2 top-4 bottom-4 w-0.5 bg-gradient-to-b from-blue-900 via-blue-700 to-sky-400 -translate-x-1/2 z-0 hidden md:block"></div>
          <div className="absolute left-6 top-4 bottom-4 w-0.5 bg-gradient-to-b from-blue-900 via-blue-700 to-sky-400 z-0 md:hidden"></div>

          {/* Timeline Nodes */}
          <div className="space-y-12 relative z-10">
            {steps.map((step, index) => {
              const Icon = step.icon;
              const isEven = index % 2 === 0;
              
              return (
                <div key={index} className="flex flex-col md:flex-row items-stretch gap-8 md:gap-0 relative">
                  
                  {/* Left spacer for desktop */}
                  <div className={`w-full md:w-1/2 md:pr-12 flex justify-end items-center ${isEven ? 'md:order-1' : 'md:order-3 md:invisible md:h-0'}`}>
                    <motion.div
                      initial={{ opacity: 0, x: isEven ? -40 : 40 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      viewport={{ once: true, margin: '-50px' }}
                      transition={{ duration: 0.5, delay: 0.1 }}
                      className={`glass p-6 rounded-2xl border ${step.glow} text-left w-full shadow-md bg-white/80`}
                    >
                      <span className="text-xs font-bold text-sky-600 font-mono">{step.date}</span>
                      <h4 className="text-lg font-bold text-slate-900 mt-1.5">{step.title}</h4>
                      <p className="text-slate-600 text-sm leading-relaxed mt-2">{step.description}</p>
                    </motion.div>
                  </div>

                  {/* Timeline Node Node (Circle) */}
                  <div className="absolute left-6 md:left-1/2 top-6 -translate-x-1/2 -translate-y-1/2 z-20 md:order-2">
                    <motion.div 
                      initial={{ scale: 0.7, opacity: 0 }}
                      whileInView={{ scale: 1, opacity: 1 }}
                      viewport={{ once: true }}
                      transition={{ type: 'spring', stiffness: 200, delay: 0.05 }}
                      className="w-12 h-12 rounded-full bg-white border-2 border-slate-200 flex items-center justify-center shadow-md relative"
                    >
                      {/* Active glow ring */}
                      <span className="absolute inset-0 rounded-full bg-sky-500/5 animate-ping opacity-30"></span>
                      <Icon className={`w-5.5 h-5.5 ${step.iconColor}`} />
                    </motion.div>
                  </div>

                  {/* Right spacer for desktop */}
                  <div className={`w-full md:w-1/2 md:pl-12 flex justify-start items-center ${!isEven ? 'md:order-3' : 'md:order-1 md:invisible md:h-0'}`}>
                    <motion.div
                      initial={{ opacity: 0, x: !isEven ? 40 : -40 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      viewport={{ once: true, margin: '-50px' }}
                      transition={{ duration: 0.5, delay: 0.1 }}
                      className={`glass p-6 rounded-2xl border ${step.glow} text-left w-full shadow-md bg-white/80`}
                    >
                      <span className="text-xs font-bold text-sky-600 font-mono">{step.date}</span>
                      <h4 className="text-lg font-bold text-slate-900 mt-1.5">{step.title}</h4>
                      <p className="text-slate-600 text-sm leading-relaxed mt-2">{step.description}</p>
                    </motion.div>
                  </div>

                </div>
              );
            })}
          </div>

        </div>

      </div>
    </section>
  );
}
