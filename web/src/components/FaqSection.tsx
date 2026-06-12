'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { HelpCircle, ChevronDown } from 'lucide-react';

const courses = [
  'Computer Science', 'Data Science', 'Electronics & Comm', 'Information Science',
  'Mechanical Eng', 'Civil Eng', 'Biotechnology', 'Electrical & Elec', 'B.Tech',
  'M.Tech', 'B.Sc Physics', 'B.Sc Chemistry', 'MBA Finance', 'BBA Marketing'
];

const campuses = [
  'REVA University', 'PES University', 'RV College of Eng', 'BMS College of Eng',
  'Ramaiah Inst of Tech', 'MIT Manipal', 'IIT Madras', 'BITS Pilani', 'VIT Vellore',
  'DTU Delhi', 'SRM University', 'NIT Trichy'
];

const faqs = [
  {
    q: 'Is ClassSync completely free to use?',
    a: 'Yes! ClassSync is open-source and free for all students. There are no subscription fees, premium tiers, or in-app advertisements.'
  },
  {
    q: 'When will the official app stores release launch?',
    a: 'We are currently under developer testing. We plan to release the official app store editions in late 2026. The APK is stable and fully functional today.'
  },
  {
    q: 'How does attendance tracking calculation work?',
    a: 'Set your threshold (e.g. 75%). Tap "Present" or "Absent" per course slot. The app shows your current percentage and tells you exactly how many consecutive lectures you need to attend if you drop below the limit.'
  },
  {
    q: 'Can I share schedules with other students?',
    a: 'Yes, each timetable creates a unique 12-digit sync code. Classmates can scan your QR code or paste this code to import your courses instantly.'
  },
  {
    q: 'Is my personal data stored securely?',
    a: 'Yes. ClassSync is local-first. All data is saved on your device in an encrypted Isar database. No user data is sent to external servers.'
  }
];

export default function FaqSection() {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  const toggleAccordion = (idx: number) => {
    setOpenIndex(openIndex === idx ? null : idx);
  };

  return (
    <section id="faq" className="relative py-16 bg-white overflow-hidden border-t border-slate-100">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-left">
        
        {/* Section Header */}
        <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight mb-8">
          Explore options in ClassSync
        </h2>

        {/* Accordions List (Zomato Explorer Style) */}
        <div className="space-y-4">
          
          {/* 1. Popular Courses Accordion */}
          <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
            <button
              onClick={() => toggleAccordion(0)}
              className="w-full p-5 text-left flex justify-between items-center font-bold text-slate-800 hover:text-slate-900 cursor-pointer bg-white"
            >
              <span className="text-base sm:text-lg">Popular courses & branches supported</span>
              <motion.div
                animate={{ rotate: openIndex === 0 ? 180 : 0 }}
                className="text-slate-500"
              >
                <ChevronDown className="w-5 h-5" />
              </motion.div>
            </button>

            <AnimatePresence initial={false}>
              {openIndex === 0 && (
                <motion.div
                  initial={{ height: 0 }}
                  animate={{ height: 'auto' }}
                  exit={{ height: 0 }}
                  className="overflow-hidden"
                >
                  <div className="p-5 pt-0 text-sm text-slate-500 leading-relaxed font-semibold">
                    <div className="flex flex-wrap gap-x-2 gap-y-1.5 items-center">
                      {courses.map((c, i) => (
                        <React.Fragment key={i}>
                          <span className="hover:text-sky-600 cursor-pointer">{c}</span>
                          {i < courses.length - 1 && <span className="w-1 h-1 rounded-full bg-slate-300 mx-1"></span>}
                        </React.Fragment>
                      ))}
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* 2. Active Campuses Accordion */}
          <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
            <button
              onClick={() => toggleAccordion(1)}
              className="w-full p-5 text-left flex justify-between items-center font-bold text-slate-800 hover:text-slate-900 cursor-pointer bg-white"
            >
              <span className="text-base sm:text-lg">Campuses using ClassSync</span>
              <motion.div
                animate={{ rotate: openIndex === 1 ? 180 : 0 }}
                className="text-slate-500"
              >
                <ChevronDown className="w-5 h-5" />
              </motion.div>
            </button>

            <AnimatePresence initial={false}>
              {openIndex === 1 && (
                <motion.div
                  initial={{ height: 0 }}
                  animate={{ height: 'auto' }}
                  exit={{ height: 0 }}
                  className="overflow-hidden"
                >
                  <div className="p-5 pt-0 text-sm text-slate-500 leading-relaxed font-semibold">
                    <div className="flex flex-wrap gap-x-2 gap-y-1.5 items-center">
                      {campuses.map((c, i) => (
                        <React.Fragment key={i}>
                          <span className="hover:text-sky-600 cursor-pointer">{c}</span>
                          {i < campuses.length - 1 && <span className="w-1 h-1 rounded-full bg-slate-300 mx-1"></span>}
                        </React.Fragment>
                      ))}
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* 3. FAQs Accordion */}
          <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
            <button
              onClick={() => toggleAccordion(2)}
              className="w-full p-5 text-left flex justify-between items-center font-bold text-slate-800 hover:text-slate-900 cursor-pointer bg-white"
            >
              <span className="text-base sm:text-lg">Frequently asked questions</span>
              <motion.div
                animate={{ rotate: openIndex === 2 ? 180 : 0 }}
                className="text-slate-500"
              >
                <ChevronDown className="w-5 h-5" />
              </motion.div>
            </button>

            <AnimatePresence initial={false}>
              {openIndex === 2 && (
                <motion.div
                  initial={{ height: 0 }}
                  animate={{ height: 'auto' }}
                  exit={{ height: 0 }}
                  className="overflow-hidden bg-slate-50/30"
                >
                  <div className="p-5 pt-0 space-y-5 border-t border-slate-100">
                    {faqs.map((faq, i) => (
                      <div key={i} className="space-y-1 pt-4 first:pt-2">
                        <h4 className="text-sm font-bold text-slate-800 flex items-center gap-1.5">
                          <HelpCircle className="w-4 h-4 text-sky-500 shrink-0" />
                          {faq.q}
                        </h4>
                        <p className="text-xs text-slate-600 pl-5.5 leading-relaxed font-semibold">
                          {faq.a}
                        </p>
                      </div>
                    ))}
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

        </div>

      </div>
    </section>
  );
}
