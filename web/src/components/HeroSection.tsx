'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Clock } from 'lucide-react';

const questions = [
  <span>What <span className="bg-gradient-to-r from-sky-500 via-sky-600 to-indigo-600 bg-clip-text text-transparent font-extrabold">class</span> is running right now?</span>,
  <span>What is your <span className="bg-gradient-to-r from-sky-500 via-sky-600 to-indigo-600 bg-clip-text text-transparent font-extrabold">next period</span>?</span>,
  <span>Which subject do you have <span className="bg-gradient-to-r from-sky-500 via-sky-600 to-indigo-600 bg-clip-text text-transparent font-extrabold">tomorrow morning</span>?</span>,
  <span>How much of today’s classes are <span className="bg-gradient-to-r from-sky-500 via-sky-600 to-indigo-600 bg-clip-text text-transparent font-extrabold">already completed</span>?</span>,
  <span>Are you sure your attendance percentage is <span className="bg-gradient-to-r from-sky-500 via-sky-600 to-indigo-600 bg-clip-text text-transparent font-extrabold">safe</span>?</span>
];

export default function HeroSection() {
  const [currentQuestionIdx, setCurrentQuestionIdx] = useState(0);
  const [time, setTime] = useState<string>('09:00:00 AM');
  
  // Live clock updater
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }));
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  // Sliding questions index updater
  useEffect(() => {
    const questionInterval = setInterval(() => {
      setCurrentQuestionIdx((prev) => (prev + 1) % questions.length);
    }, 3000);
    return () => clearInterval(questionInterval);
  }, []);

  return (
    <section className="relative min-h-[98vh] sm:min-h-[101vh] lg:min-h-[104vh] flex flex-col items-center justify-center pt-32 pb-24 px-4 overflow-hidden bg-transparent">
      {/* Background patterns: Premium clean grids & liquid layout elements */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,rgba(14,165,233,0.015)_1px,transparent_1px),linear-gradient(to_bottom,rgba(14,165,233,0.015)_1px,transparent_1px)] bg-[size:3.5rem_3.5rem] z-0"></div>
      
      {/* Glowing backdrops */}
      <div className="absolute top-1/4 left-1/3 -translate-x-1/2 bg-sky-400/8 w-[500px] h-[250px] rounded-full blur-[100px] z-0"></div>
      <div className="absolute bottom-1/4 right-1/4 bg-blue-900/8 w-[400px] h-[200px] rounded-full blur-[120px] z-0"></div>

      {/* Floating Animated Timetable Elements */}
      <div className="absolute inset-0 pointer-events-none hidden lg:block overflow-hidden z-10">
        
        {/* Floating Card 1: Subject Period Indicator */}
        <motion.div 
          className="absolute top-[22%] left-[8%] w-[250px] p-4 rounded-2xl glass shadow-md border border-slate-200/80 animate-float"
        >
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Ongoing Period</span>
          </div>
          <h4 className="text-sm font-extrabold text-slate-800">Advanced CSE Seminar</h4>
          <p className="text-xs text-slate-500 font-semibold mt-0.5">Room 402B · Prof. Watson</p>
          <div className="w-full bg-slate-100 rounded-full h-1.5 mt-3 overflow-hidden">
            <div className="bg-sky-500 h-1.5 rounded-full w-[65%]"></div>
          </div>
          <div className="flex justify-between items-center text-[9px] text-slate-400 font-bold mt-2">
            <span>65% completed</span>
            <span>15 mins left</span>
          </div>
        </motion.div>

        {/* Floating Card 2: Live Clock Widget */}
        <motion.div 
          className="absolute top-[35%] right-[7%] w-[220px] p-4 rounded-2xl glass shadow-md border border-slate-200/80 animate-float-delayed flex items-center gap-3.5"
        >
          <div className="w-10 h-10 rounded-xl bg-sky-50 flex items-center justify-center text-sky-500 shrink-0">
            <Clock className="w-5 h-5" />
          </div>
          <div className="text-left">
            <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest block">ClassSync Clock</span>
            <span className="text-sm font-black text-slate-800 font-mono tracking-tight block mt-0.5">{time}</span>
            <span className="text-[9px] text-sky-600 font-semibold block">In sync with university hub</span>
          </div>
        </motion.div>

        {/* Floating Card 3: Attendance tracker widget */}
        <motion.div 
          className="absolute bottom-[20%] left-[10%] w-[190px] p-3.5 rounded-2xl glass shadow-md border border-slate-200/80 animate-float-delayed"
        >
          <div className="flex items-center justify-between mb-2">
            <span className="text-[10px] font-extrabold text-slate-700 uppercase tracking-wider">Attendance Rate</span>
            <span className="px-1.5 py-0.5 bg-emerald-50 text-[8px] font-black text-emerald-600 border border-emerald-100 rounded">
              SAFE
            </span>
          </div>
          <div className="flex items-baseline gap-1">
            <span className="text-xl font-black text-slate-900">82.4%</span>
            <span className="text-[9px] text-slate-400 font-semibold">Overall</span>
          </div>
          <p className="text-[9.5px] text-slate-500 font-medium mt-1">Next: Math class attendance is critical</p>
        </motion.div>

      </div>

      <div className="max-w-5xl mx-auto text-center space-y-10 relative z-20 w-full">
        {/* Dynamic Sliding Headline Questions (Centered, Relative normal-flow rendering to fix spacing) */}
        <div 
          className="h-[315px] sm:h-[386px] md:h-[443px] lg:h-[386px] flex items-center justify-center overflow-hidden relative w-full"
          style={{ perspective: 1200 }}
        >
          <AnimatePresence mode="wait">
            <motion.h1 
              key={currentQuestionIdx}
              initial={{ opacity: 0, y: 30, scale: 0.96, rotateX: -12 }}
              animate={{ opacity: 1, y: 0, scale: 1, rotateX: 0 }}
              exit={{ opacity: 0, y: -30, scale: 0.96, rotateX: 12 }}
              transition={{ 
                type: "spring",
                stiffness: 110,
                damping: 16,
                opacity: { duration: 0.2 }
              }}
              className="w-full max-w-4xl px-4 text-center text-[47px] sm:text-[62px] md:text-[78px] lg:text-[94px] font-extrabold text-slate-900 tracking-tight leading-snug select-none"
            >
              {questions[currentQuestionIdx]}
            </motion.h1>
          </AnimatePresence>
        </div>

        {/* Static Marketing Subheadline */}
        <div className="space-y-4 pt-2">
          <motion.p 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="text-sm sm:text-base md:text-lg text-slate-900 font-medium max-w-3xl mx-auto leading-relaxed px-4"
          >
            Know your current class, upcoming lectures, attendance percentage, daily progress, and complete timetable instantly. All in one place.
          </motion.p>
        </div>
      </div>
    </section>
  );
}
