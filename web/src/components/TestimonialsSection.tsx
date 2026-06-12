'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronLeft, ChevronRight, Quote, MessageSquare, Star } from 'lucide-react';

const testimonials = [
  {
    quote: "The widgets are a lifesaver. I can see my next class and room number right on my home screen without opening any messy PDFs or group chat pins.",
    author: "Rohan Mehta",
    role: "Semester 4, CSE",
    college: "REVA University",
  },
  {
    quote: "Before ClassSync, I was constantly getting caught with low attendance because I couldn't calculate it. Now, the dashboard tells me exactly where I stand.",
    author: "Alice D'Souza",
    role: "Semester 6, ECE",
    college: "PES Institute",
  },
  {
    quote: "Love the Sync Code feature. One representative in our class section created the timetable and shared the code. We all imported it in under 5 seconds!",
    author: "Priya Sharma",
    role: "Semester 2, ISE",
    college: "RV College of Eng",
  },
  {
    quote: "It loads instantly and the Material dark mode is very clean. Adding a slot takes literally 10 seconds. Sideloading the APK took a minute and was totally worth it.",
    author: "Alex G.",
    role: "Semester 4, ME",
    college: "BMSCE",
  },
];

export default function TestimonialsSection() {
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setActiveIndex((prev) => (prev + 1) % testimonials.length);
    }, 6000);
    return () => clearInterval(timer);
  }, []);

  const handlePrev = () => {
    setActiveIndex((prev) => (prev === 0 ? testimonials.length - 1 : prev - 1));
  };

  const handleNext = () => {
    setActiveIndex((prev) => (prev + 1) % testimonials.length);
  };

  return (
    <section className="relative py-24 bg-gradient-to-b from-white to-slate-50 overflow-hidden border-t border-slate-100">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
        
        {/* Section Header */}
        <div className="flex flex-col items-center gap-4 mb-12">
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-indigo-50 border border-indigo-200 text-indigo-600 text-xs font-bold">
            <MessageSquare className="w-3.5 h-3.5" /> Peer Feedback
          </span>
          <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
            What Other Students Are Saying
          </h2>
        </div>

        {/* Testimonial Box */}
        <div className="min-h-[220px] relative flex items-center justify-center">
          <Quote className="absolute -top-6 left-2 w-16 h-16 text-slate-100 pointer-events-none z-0" />
          
          <AnimatePresence mode="wait">
            <motion.div
              key={activeIndex}
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -15 }}
              transition={{ duration: 0.3 }}
              className="relative z-10 space-y-6 max-w-2xl mx-auto"
            >
              <p className="text-lg sm:text-xl text-slate-700 leading-relaxed italic font-light">
                "{testimonials[activeIndex].quote}"
              </p>
              
              <div>
                <h4 className="text-base font-extrabold text-slate-900">
                  {testimonials[activeIndex].author}
                </h4>
                <p className="text-xs text-sky-600 font-bold mt-1">
                  {testimonials[activeIndex].role} · {testimonials[activeIndex].college}
                </p>
              </div>
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Carousel Controls */}
        <div className="flex items-center justify-center gap-4 mt-10">
          <button 
            onClick={handlePrev}
            className="w-10 h-10 rounded-full bg-white border border-slate-200 text-slate-500 hover:text-slate-800 hover:border-slate-300 flex items-center justify-center cursor-pointer active:scale-95 transition-all shadow-sm"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          
          {/* Indicators */}
          <div className="flex items-center gap-2">
            {testimonials.map((_, idx) => (
              <span 
                key={idx}
                onClick={() => setActiveIndex(idx)}
                className={`h-2 rounded-full transition-all duration-300 cursor-pointer ${
                  activeIndex === idx ? 'w-6 bg-sky-500' : 'w-2 bg-slate-200'
                }`}
              ></span>
            ))}
          </div>

          <button 
            onClick={handleNext}
            className="w-10 h-10 rounded-full bg-white border border-slate-200 text-slate-500 hover:text-slate-800 hover:border-slate-300 flex items-center justify-center cursor-pointer active:scale-95 transition-all shadow-sm"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>

      </div>
    </section>
  );
}
