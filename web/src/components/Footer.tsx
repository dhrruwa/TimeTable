'use client';

import React from 'react';
import { Calendar, Globe, Heart, Shield, RefreshCw } from 'lucide-react';

export default function Footer() {
  const currentYear = new Date().getFullYear();

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <footer className="relative bg-slate-50 border-t border-slate-200 pt-16 pb-8 overflow-hidden">
      {/* Background radial highlight */}
      <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-full max-w-7xl h-96 bg-gradient-to-t from-blue-100/20 via-transparent to-transparent pointer-events-none rounded-full blur-3xl"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-12">
        
        {/* Top Header Row (Zomato style) */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6 border-b border-slate-200 pb-8">
          {/* Logo */}
          <div className="flex items-center gap-2 cursor-pointer text-left" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}>
            <img src="/logo.png" alt="ClassSync Logo" className="h-[60px] w-auto object-contain" />
          </div>

          {/* Selectors */}
          <div className="flex items-center gap-3">
            {/* Country Selector */}
            <div className="px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 flex items-center gap-1.5 shadow-2xs select-none">
              <span>🇮🇳</span>
              <span>India</span>
            </div>

            {/* Language Selector */}
            <div className="px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-xs font-bold text-slate-700 flex items-center gap-1.5 shadow-2xs select-none">
              <Globe className="w-3.5 h-3.5 text-slate-500" />
              <span>English</span>
            </div>
          </div>
        </div>

        {/* Link Columns Grid */}
        <div className="grid grid-cols-2 md:grid-cols-5 gap-8 text-left">
          
          {/* Col 1 */}
          <div className="space-y-4">
            <h3 className="text-xs font-extrabold text-slate-800 uppercase tracking-widest">About ClassSync</h3>
            <ul className="space-y-2.5 text-xs text-slate-500 font-semibold">
              <li><button onClick={() => scrollToSection('story')} className="hover:text-slate-800 transition-colors">Who We Are</button></li>
              <li><a href="#" className="hover:text-slate-800 transition-colors">Student Blog</a></li>
              <li><a href="#" className="hover:text-slate-800 transition-colors">Join the Team</a></li>
              <li>
                <button 
                  onClick={(e) => {
                    e.preventDefault();
                    window.dispatchEvent(new CustomEvent('open-support-widget'));
                  }}
                  className="hover:text-slate-800 transition-colors text-left cursor-pointer bg-transparent border-0 p-0 text-slate-500 font-semibold"
                >
                  Contact Developer
                </button>
              </li>
            </ul>
          </div>

          {/* Col 2 */}
          <div className="space-y-4">
            <h3 className="text-xs font-extrabold text-slate-800 uppercase tracking-widest">For Students</h3>
            <ul className="space-y-2.5 text-xs text-slate-500 font-semibold">
              <li><button onClick={() => scrollToSection('download')} className="hover:text-slate-800 transition-colors">Download APK</button></li>
              <li><button onClick={() => scrollToSection('showcase')} className="hover:text-slate-800 transition-colors">Weekly Planner</button></li>
              <li><button onClick={() => scrollToSection('features')} className="hover:text-slate-800 transition-colors">Attendance Manager</button></li>
              <li><a href="#" className="hover:text-slate-800 transition-colors">Sync Codes Guide</a></li>
            </ul>
          </div>

          {/* Col 3 */}
          <div className="space-y-4">
            <h3 className="text-xs font-extrabold text-slate-800 uppercase tracking-widest">For Campuses</h3>
            <ul className="space-y-2.5 text-xs text-slate-500 font-semibold">
              <li><a href="#" className="hover:text-slate-800 transition-colors">Add Campus Timetable</a></li>
              <li><a href="#" className="hover:text-slate-800 transition-colors">Verification Badge</a></li>
              <li><a href="#" className="hover:text-slate-800 transition-colors">API Timetable Sync</a></li>
            </ul>
          </div>

          {/* Col 4 */}
          <div className="space-y-4">
            <h3 className="text-xs font-extrabold text-slate-800 uppercase tracking-widest">Learn More</h3>
            <ul className="space-y-2.5 text-xs text-slate-500 font-semibold">
              <li><a href="#" className="hover:text-slate-800 transition-colors">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-slate-800 transition-colors">Terms of Service</a></li>
              <li><a href="#" className="hover:text-slate-800 transition-colors">Security Details</a></li>
              <li><a href="/admin" className="hover:text-slate-800 transition-colors flex items-center gap-1"><RefreshCw className="w-3 h-3 text-sky-500" /> Admin Access</a></li>
            </ul>
          </div>

          {/* Col 5: Social Links & App store badges */}
          <div className="col-span-2 md:col-span-1 space-y-5">
            <h3 className="text-xs font-extrabold text-slate-800 uppercase tracking-widest">Social Links</h3>
            
            {/* Social Icons */}
            <div className="flex items-center gap-3 text-slate-600">
              <a href="https://github.com/dhrruwa" target="_blank" rel="noreferrer" className="w-8 h-8 rounded-full bg-slate-200/50 hover:bg-slate-200 flex items-center justify-center transition-colors">
                <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                  <path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 21.795 24 17.3 24 12c0-6.63-5.37-12-12-12z"/>
                </svg>
              </a>

              <a href="https://www.linkedin.com/in/dhrru-wa-66b4b4305?utm_source=share_via&utm_content=profile&utm_medium=member_ios" className="w-8 h-8 rounded-full bg-slate-200/50 hover:bg-slate-200 flex items-center justify-center transition-colors">
                <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                  <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.779-1.75-1.75s.784-1.75 1.75-1.75 1.75.779 1.75 1.75-.784 1.75-1.75 1.75zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/>
                </svg>
              </a>

            </div>

            {/* Badges */}
            <div className="flex flex-col gap-2.5 max-w-[125px]">
              {/* Play Store Badge */}
              <div className="flex items-center gap-1.5 px-2.5 py-1 bg-slate-950 text-white rounded-md border border-slate-800 cursor-pointer opacity-90 hover:opacity-100 transition-opacity">
                <svg className="w-4 h-4 fill-current shrink-0" viewBox="0 0 24 24">
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a1.91 1.91 0 01-.61-1.393V3.207c0-.528.22-1.018.61-1.393zM15.207 13.414l3.186-3.186L15.207 7.042l-2.83 2.83 2.83 2.832zm.708-.707l3.889-3.89 1.104 1.105c.488.487.488 1.278 0 1.765l-1.104 1.106-3.889-3.886zm-12.306 9.48l10.183-10.183 2.83 2.83-9.529 9.53a1.91 1.91 0 01-2.915-.093l-1.89-1.92L3.609 22.187z"/>
                </svg>
                <div className="text-[6.5px] font-bold text-left leading-tight shrink-0">
                  <span>GET IT ON</span>
                  <span className="block text-[9px] font-black">Google Play</span>
                </div>
              </div>

              {/* App Store Badge */}
              <div className="flex items-center gap-1.5 px-2.5 py-1 bg-slate-950 text-white rounded-md border border-slate-800 cursor-pointer opacity-90 hover:opacity-100 transition-opacity">
                <svg className="w-4 h-4 fill-current shrink-0" viewBox="0 0 24 24">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.17.67-2.88 1.48-.62.71-1.16 1.85-1.01 2.96 1.11.09 2.24-.57 2.9-1.38z"/>
                </svg>
                <div className="text-[6.5px] font-bold text-left leading-tight shrink-0">
                  <span>Download on the</span>
                  <span className="block text-[9px] font-black">App Store</span>
                </div>
              </div>
            </div>

          </div>

        </div>

        {/* Bottom fine print */}
        <div className="border-t border-slate-200 pt-8 flex flex-col md:flex-row items-center justify-between gap-4 text-center md:text-left">
          <p className="text-xs text-slate-400 font-medium">
            By continuing past this page, you agree to our Terms of Service, Cookie Policy, Privacy Policy and Content Policies. All trademarks are properties of their respective owners. &copy; {currentYear} ClassSync. All rights reserved.
          </p>
          <span className="text-xs text-slate-400 flex items-center justify-center gap-1 font-medium shrink-0">
            Made with <Heart className="w-3.5 h-3.5 text-rose-500 fill-rose-500" /> for colleges.
          </span>
        </div>

      </div>
    </footer>
  );
}
