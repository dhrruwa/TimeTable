'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronRight, ChevronDown, ChevronUp, MapPin } from 'lucide-react';

// Wait! Let's make sure we type "framer-motion" correctly. Yes: from 'framer-motion'

const initialColleges = [
  { name: 'REVA University', location: 'Bangalore', count: '1,248 students' },
  { name: 'PES University', location: 'Bangalore', count: '982 students' },
  { name: 'RV College of Engineering', location: 'Bangalore', count: '1,150 students' },
  { name: 'BMS College of Engineering', location: 'Bangalore', count: '740 students' },
  { name: 'Ramaiah Institute of Technology', location: 'Bangalore', count: '890 students' },
  { name: 'MIT Manipal', location: 'Manipal', count: '1,050 students' },
  { name: 'IIT Madras', location: 'Chennai', count: '450 students' },
  { name: 'BITS Pilani', location: 'Pilani', count: '670 students' },
];

const extraColleges = [
  { name: 'Delhi Technological University', location: 'Delhi', count: '820 students' },
  { name: 'Vellore Institute of Technology', location: 'Vellore', count: '1,450 students' },
  { name: 'SRM Institute of Science', location: 'Chennai', count: '980 students' },
  { name: 'NIT Trichy', location: 'Trichy', count: '510 students' },
];

export default function CollegesGrid() {
  const [showAll, setShowAll] = useState(false);
  
  const displayedColleges = showAll ? [...initialColleges, ...extraColleges] : initialColleges;

  const handleCollegeClick = (name: string) => {
    // Scroll to showcase section
    const element = document.getElementById('showcase');
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section className="relative py-16 bg-white overflow-hidden border-t border-slate-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-left space-y-12">
        
        {/* Header */}
        <div className="space-y-2">
          <h2 className="text-3xl font-extrabold text-slate-900 tracking-tight">
            Popular colleges active on ClassSync
          </h2>
          <p className="text-slate-500 text-sm font-semibold flex items-center gap-1">
            <MapPin className="w-4 h-4 text-sky-500" /> Connecting students across campuses. Find your schedule slots.
          </p>
        </div>

        {/* Colleges Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {displayedColleges.map((col, idx) => (
            <div
              key={idx}
              onClick={() => handleCollegeClick(col.name)}
              className="p-5 rounded-2xl border border-slate-200 bg-white hover:shadow-md transition-all duration-300 flex items-center justify-between cursor-pointer group shadow-2xs"
            >
              <div className="space-y-0.5 text-left overflow-hidden pr-4">
                <h3 className="text-sm font-extrabold text-slate-800 truncate group-hover:text-sky-600 transition-colors">
                  {col.name}
                </h3>
                <span className="text-xs text-slate-500 font-semibold block">
                  {col.count} · {col.location}
                </span>
              </div>
              <ChevronRight className="w-5 h-5 text-slate-400 group-hover:text-slate-600 shrink-0 transition-transform group-hover:translate-x-1" />
            </div>
          ))}

          {/* Show More toggle button card */}
          <div
            onClick={() => setShowAll(!showAll)}
            className="p-5 rounded-2xl border border-slate-200 bg-white hover:bg-slate-50/50 hover:shadow-md transition-all duration-300 flex items-center justify-center cursor-pointer group shadow-2xs font-bold text-sm text-slate-700"
          >
            <div className="flex items-center gap-1.5">
              {showAll ? (
                <>
                  <span>Show Less</span>
                  <ChevronUp className="w-4 h-4 text-slate-500 group-hover:text-slate-800" />
                </>
              ) : (
                <>
                  <span>Show More ({extraColleges.length} campuses)</span>
                  <ChevronDown className="w-4 h-4 text-slate-500 group-hover:text-slate-800" />
                </>
              )}
            </div>
          </div>
        </div>

      </div>
    </section>
  );
}
