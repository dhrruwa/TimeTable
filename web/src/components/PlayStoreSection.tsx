'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Play, Sparkles } from 'lucide-react';

export default function PlayStoreSection() {
  return (
    <section className="relative py-12 bg-white overflow-hidden border-t border-slate-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10">
        
        <div className="flex flex-col items-center gap-6">
          <p className="text-xs uppercase tracking-widest text-slate-500 font-bold flex items-center gap-1.5">
            <Sparkles className="w-3.5 h-3.5 text-sky-500" /> Official Stores Roadmap
          </p>

          <div className="flex flex-wrap justify-center items-center gap-6">
            
            {/* Google Play Store Badge */}
            <motion.div 
              whileHover={{ scale: 1.02 }}
              className="glass p-5 rounded-2xl border border-slate-200 bg-white flex items-center gap-4 text-left max-w-xs shadow-sm relative overflow-hidden"
            >
              <div className="absolute top-2 right-2 px-1.5 py-0.5 rounded text-[8px] font-bold bg-sky-50 text-sky-600 border border-sky-200">
                SOON
              </div>
              <div className="w-12 h-12 rounded-xl bg-slate-50 border border-slate-200/60 flex items-center justify-center text-sky-500 fill-sky-500">
                <Play className="w-6 h-6" />
              </div>
              <div>
                <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Get it on</p>
                <p className="text-base font-extrabold text-slate-900">Google Play</p>
                <p className="text-[10px] text-slate-500 mt-0.5">Under developer review</p>
              </div>
            </motion.div>

            {/* Apple App Store Badge */}
            <motion.div 
              whileHover={{ scale: 1.02 }}
              className="glass p-5 rounded-2xl border border-slate-200 bg-white flex items-center gap-4 text-left max-w-xs shadow-sm relative overflow-hidden"
            >
              <div className="absolute top-2 right-2 px-1.5 py-0.5 rounded text-[8px] font-bold bg-indigo-50 text-indigo-600 border border-indigo-200">
                SOON
              </div>
              <div className="w-12 h-12 rounded-xl bg-slate-50 border border-slate-200/60 flex items-center justify-center text-sky-500">
                <svg className="w-6 h-6 text-sky-500 fill-sky-500" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.17.67-2.88 1.48-.62.71-1.16 1.85-1.01 2.96 1.11.09 2.24-.57 2.9-1.38z"/>
                </svg>
              </div>
              <div>
                <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Download on the</p>
                <p className="text-base font-extrabold text-slate-900">App Store</p>
                <p className="text-[10px] text-slate-500 mt-0.5">iOS Simulator supported</p>
              </div>
            </motion.div>

          </div>
        </div>

      </div>
    </section>
  );
}
