'use client';

import React, { useState, useEffect } from 'react';
import { Calendar, Menu, X, ArrowDownToLine } from 'lucide-react';

export default function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToSection = (id: string) => {
    setIsMobileMenuOpen(false);
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
      isScrolled ? 'py-3 bg-white/75 border-b border-slate-200/50 backdrop-blur-md shadow-sm' : 'py-5 bg-transparent'
    }`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <div className="flex items-center gap-2 cursor-pointer relative md:left-[2%] left-0" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}>
            {/* Logo is 20% larger (72px) but a negative margin keeps its layout
                footprint at 60px, so the navbar height is unchanged. */}
            <img src="/logo.png" alt="ClassSync Logo" className="h-[100px] w-auto object-contain my-[-40px]" />
          </div>

          {/* Desktop Nav Links */}
          <div className="hidden md:flex items-center gap-8">
            <button onClick={() => scrollToSection('features')} className="text-sm text-slate-600 hover:text-sky-600 transition-colors font-semibold cursor-pointer">
              Features
            </button>
            <button onClick={() => scrollToSection('problem')} className="text-sm text-slate-600 hover:text-sky-600 transition-colors font-semibold cursor-pointer">
              Why Us
            </button>
            <button onClick={() => scrollToSection('story')} className="text-sm text-slate-600 hover:text-sky-600 transition-colors font-semibold cursor-pointer">
              Our Story
            </button>
            <button onClick={() => scrollToSection('showcase')} className="text-sm text-slate-600 hover:text-sky-600 transition-colors font-semibold cursor-pointer">
              Showcase
            </button>
            <button onClick={() => scrollToSection('faq')} className="text-sm text-slate-600 hover:text-sky-600 transition-colors font-semibold cursor-pointer">
              FAQ
            </button>
          </div>

          {/* Download Button */}
          <div className="hidden md:block">
            <button
              onClick={() => scrollToSection('download')}
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-sky-500 hover:bg-sky-600 text-white font-semibold text-sm transition-all duration-300 hover:shadow-lg hover:shadow-sky-500/25 active:scale-95 cursor-pointer"
            >
              <ArrowDownToLine className="w-4 h-4" />
              Download APK
            </button>
          </div>

          {/* Mobile Menu Button */}
          <div className="md:hidden">
            <button
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
              className="p-2 rounded-lg bg-slate-50 border border-slate-200 text-slate-600 hover:text-slate-900"
            >
              {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer */}
      {isMobileMenuOpen && (
        <div className="md:hidden absolute top-full left-0 right-0 py-6 bg-white border-b border-slate-200 backdrop-blur-xl shadow-lg animate-in fade-in slide-in-from-top-5 duration-200">
          <div className="flex flex-col px-4 gap-4">
            <button onClick={() => scrollToSection('features')} className="text-left py-2 text-base text-slate-600 hover:text-sky-600 transition-colors font-semibold">
              Features
            </button>
            <button onClick={() => scrollToSection('problem')} className="text-left py-2 text-base text-slate-600 hover:text-sky-600 transition-colors font-semibold">
              Why Us
            </button>
            <button onClick={() => scrollToSection('story')} className="text-left py-2 text-base text-slate-600 hover:text-sky-600 transition-colors font-semibold">
              Our Story
            </button>
            <button onClick={() => scrollToSection('showcase')} className="text-left py-2 text-base text-slate-600 hover:text-sky-600 transition-colors font-semibold">
              Showcase
            </button>
            <button onClick={() => scrollToSection('faq')} className="text-left py-2 text-base text-slate-600 hover:text-sky-600 transition-colors font-semibold">
              FAQ
            </button>
            <button
              onClick={() => scrollToSection('download')}
              className="flex items-center justify-center gap-2 w-full py-3 mt-2 rounded-xl bg-sky-500 text-white font-semibold transition-all hover:bg-sky-600"
            >
              <ArrowDownToLine className="w-5 h-5" />
              Download APK
            </button>
          </div>
        </div>
      )}
    </nav>
  );
}
