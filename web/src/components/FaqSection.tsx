'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, LifeBuoy } from 'lucide-react';

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

  const toggle = (idx: number) => setOpenIndex(openIndex === idx ? null : idx);

  return (
    <section id="faq" className="relative py-16 bg-white overflow-hidden border-t border-slate-100">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-left">

        {/* Section Header */}
        <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight mb-8">
          Frequently asked questions
        </h2>

        {/* FAQ Accordions */}
        <div className="space-y-4">
          {faqs.map((faq, idx) => (
            <div key={idx} className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
              <button
                onClick={() => toggle(idx)}
                className="w-full p-5 text-left flex justify-between items-center font-bold text-slate-800 hover:text-slate-900 cursor-pointer bg-white"
              >
                <span className="text-base sm:text-lg">{faq.q}</span>
                <motion.div
                  animate={{ rotate: openIndex === idx ? 180 : 0 }}
                  className="text-slate-500 shrink-0 ml-4"
                >
                  <ChevronDown className="w-5 h-5" />
                </motion.div>
              </button>

              <AnimatePresence initial={false}>
                {openIndex === idx && (
                  <motion.div
                    initial={{ height: 0 }}
                    animate={{ height: 'auto' }}
                    exit={{ height: 0 }}
                    className="overflow-hidden"
                  >
                    <p className="p-5 pt-0 text-sm text-slate-600 leading-relaxed font-semibold">
                      {faq.a}
                    </p>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>

        {/* Support button */}
        <div className="mt-10 flex flex-col items-center text-center gap-3">
          <p className="text-slate-600 font-semibold">Still have a question?</p>
          <button
            onClick={(e) => {
              e.preventDefault();
              window.dispatchEvent(new CustomEvent('open-support-widget'));
            }}
            className="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-sky-500 hover:bg-sky-600 text-white font-semibold transition-all duration-300 hover:shadow-lg hover:shadow-sky-500/25 active:scale-95 cursor-pointer"
          >
            <LifeBuoy className="w-5 h-5" />
            Contact Support
          </button>
        </div>

      </div>
    </section>
  );
}
