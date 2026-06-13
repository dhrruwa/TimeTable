'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowDownToLine, CheckCircle2, ShieldCheck, Mail, Smartphone, Download, User } from 'lucide-react';
import { trackDownload, subscribeNewsletter } from '../lib/db';
import confetti from 'canvas-confetti';

export default function DownloadSection() {
  const [contactType, setContactType] = useState<'email' | 'direct'>('email');
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  
  const [actionStatus, setActionStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [statusMsg, setStatusMsg] = useState('');

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !email.trim()) {
      setActionStatus('error');
      setStatusMsg('Name and email are required.');
      return;
    }

    setActionStatus('loading');
    try {
      const res = await subscribeNewsletter(name, email);
      if (res.success) {
        // Trigger background SMTP dispatch to send the confirmation email
        fetch('/api/send-app-link', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name, email }),
        }).catch(err => console.error('Background email dispatch failed:', err));

        setActionStatus('success');
        setStatusMsg(res.message);
        setName('');
        setEmail('');
        confetti({
          particleCount: 80,
          spread: 50,
          origin: { y: 0.8 },
          colors: ['#0ea5e9', '#38bdf8', '#ffffff'],
        });
      } else {
        setActionStatus('error');
        setStatusMsg(res.message);
      }
    } catch (err: any) {
      setActionStatus('error');
      setStatusMsg('Failed to subscribe, please try again.');
    }
  };

  const handleDirectDownload = async () => {
    setActionStatus('loading');
    try {
      await trackDownload();
      confetti({
        particleCount: 150,
        spread: 80,
        origin: { y: 0.6 },
        colors: ['#0ea5e9', '#38bdf8', '#4f46e5', '#ffffff'],
      });

      // Initiate download
      const link = document.createElement('a');
      link.href = '/timetable.apk';
      link.download = 'timetable.apk';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      setActionStatus('success');
      setStatusMsg('Download initialized successfully!');
      setTimeout(() => {
        setActionStatus('idle');
        setStatusMsg('');
      }, 5000);
    } catch (err) {
      setActionStatus('error');
      setStatusMsg('Download failed.');
    }
  };

  return (
    <section id="download" className="relative py-20 bg-slate-50 overflow-hidden border-t border-slate-100">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Phone Mockup (Zomato Mockup Style) */}
          <div className="lg:col-span-5 flex justify-center lg:justify-end order-2 lg:order-1">
            <div className="relative">
              {/* Soft decorative shadow behind device */}
              <div className="absolute inset-0 bg-sky-500/5 blur-[50px] rounded-[48px] scale-90"></div>

              {/* iPhone chassis mockup */}
              <div className="phone-mockup w-[286px] h-[572px] rounded-[40px] bg-white border-[8px] border-slate-950 shadow-2xl relative overflow-hidden flex flex-col ring-1 ring-slate-950/20">
                {/* Dynamic island */}
                <div className="absolute top-2 left-1/2 -translate-x-1/2 w-24 h-5 rounded-full bg-slate-950 z-30"></div>
                
                {/* Simulated Screen */}
                <div className="phone-screen flex-1 bg-white p-4 pt-8 flex flex-col justify-start text-left text-slate-800">
                  <div className="flex justify-between items-center pb-3 border-b border-slate-100">
                    <div>
                      <span className="text-[8px] text-slate-400 font-bold block uppercase tracking-wider">Dashboard</span>
                      <span className="text-xs font-extrabold text-slate-900">Hey, Student!</span>
                    </div>
                    <span className="w-5 h-5 rounded-full bg-sky-50 flex items-center justify-center text-sky-500">
                      <Smartphone className="w-3 h-3" />
                    </span>
                  </div>

                  {/* Now running */}
                  <div className="p-3 bg-slate-50 border border-slate-200/60 rounded-xl mt-4 space-y-2">
                    <span className="text-[8.5px] uppercase font-bold text-sky-600 tracking-wider block">Class now running</span>
                    <p className="text-xs font-bold text-slate-900 leading-tight">Software Engineering</p>
                    <p className="text-[8.5px] text-slate-500">Room 304B · Dr. Sarah</p>
                  </div>

                  {/* Attendance ring preview */}
                  <div className="p-3 bg-slate-50 border border-slate-200/60 rounded-xl mt-3 flex items-center justify-between">
                    <div>
                      <span className="text-[8.5px] uppercase font-bold text-slate-500 block">Maths Attendance</span>
                      <span className="text-sm font-black text-slate-950 mt-1 block">82.4%</span>
                    </div>
                    <span className="text-[8px] font-bold text-emerald-600 bg-emerald-50 border border-emerald-150 px-1.5 py-0.5 rounded">
                      SAFE
                    </span>
                  </div>

                  {/* Quick stats footer */}
                  <div className="mt-auto p-2 bg-sky-50 border border-sky-100/50 rounded-lg flex items-center gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-sky-500 animate-ping"></div>
                    <span className="text-[8px] font-semibold text-sky-600">3/5 Classes Completed Today</span>
                  </div>
                </div>

                {/* Home line */}
                <div className="h-4 flex items-center justify-center pb-1">
                  <div className="w-20 h-1 rounded-full bg-slate-200"></div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: Download Form Content (Zomato Form Style) */}
          <div className="lg:col-span-7 text-left space-y-6 order-1 lg:order-2 max-w-xl mx-auto lg:mx-0">
            <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">
              Get the ClassSync App
            </h2>
            <p className="text-slate-600 text-sm sm:text-base leading-relaxed font-semibold">
              Sideload the stable Android APK directly or register with your email address to receive official App Store and Google Play release notifications.
            </p>

            {/* Selector: Email vs Direct Link */}
            <div className="flex items-center gap-6 text-sm text-slate-600 font-bold select-none">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="contactType"
                  checked={contactType === 'email'}
                  onChange={() => {
                    setContactType('email');
                    setActionStatus('idle');
                    setStatusMsg('');
                  }}
                  className="w-4.5 h-4.5 text-sky-500 focus:ring-sky-500"
                />
                <span>Email Early Access</span>
              </label>

              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="contactType"
                  checked={contactType === 'direct'}
                  onChange={() => {
                    setContactType('direct');
                    setActionStatus('idle');
                    setStatusMsg('');
                  }}
                  className="w-4.5 h-4.5 text-sky-500 focus:ring-sky-500"
                />
                <span>Direct APK Download</span>
              </label>
            </div>

            {/* Input Action Panels */}
            <div className="min-h-[140px] pt-2">
              <AnimatePresence mode="wait">
                
                {/* 1. EMAIL FORM */}
                {contactType === 'email' && (
                  <motion.div
                    key="email"
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: 10 }}
                    className="space-y-4"
                  >
                    {actionStatus === 'success' ? (
                      <div className="p-6 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-start sm:items-center gap-4 text-left shadow-2xs">
                        <div className="w-10 h-10 rounded-full bg-emerald-100/80 flex items-center justify-center text-emerald-600 shrink-0">
                          <CheckCircle2 className="w-5 h-5 animate-bounce" />
                        </div>
                        <div>
                          <p className="font-black text-sm text-slate-900">Registered Successfully!</p>
                          <p className="text-xs text-slate-650 font-bold leading-relaxed mt-1">
                            Early access registered! We have sent a confirmation details email to you. Please check your inbox.
                          </p>
                        </div>
                      </div>
                    ) : (
                      <form onSubmit={handleEmailSubmit} className="flex flex-col sm:flex-row gap-3">
                        <div className="relative flex-1">
                          <User className="w-4.5 h-4.5 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
                          <input
                            type="text"
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            placeholder="Your Name"
                            className="w-full pl-11 pr-4 py-3 rounded-xl bg-white border border-slate-200 text-slate-800 focus:outline-none focus:border-sky-500 text-sm font-semibold shadow-2xs"
                            disabled={actionStatus === 'loading'}
                          />
                        </div>

                        <div className="relative flex-[1.5]">
                          <Mail className="w-4.5 h-4.5 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
                          <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="Email address"
                            className="w-full pl-11 pr-4 py-3 rounded-xl bg-white border border-slate-200 text-slate-800 focus:outline-none focus:border-sky-500 text-sm font-semibold shadow-2xs"
                            disabled={actionStatus === 'loading'}
                          />
                        </div>

                        <button
                          type="submit"
                          disabled={actionStatus === 'loading'}
                          className="px-6 py-3 rounded-xl bg-gradient-to-r from-blue-900 to-sky-500 hover:from-blue-950 hover:to-sky-600 text-white font-bold text-sm transition-colors cursor-pointer shrink-0 disabled:opacity-50"
                        >
                          {actionStatus === 'loading' ? 'Sending...' : 'Get App Link'}
                        </button>
                      </form>
                    )}
                    {actionStatus === 'error' && (
                      <p className="text-xs text-rose-500 font-semibold pl-1">{statusMsg}</p>
                    )}
                  </motion.div>
                )}

                {/* 2. DIRECT APK DOWNLOAD */}
                {contactType === 'direct' && (
                  <motion.div
                    key="direct"
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: 10 }}
                    className="space-y-4"
                  >
                    <div className="flex flex-col sm:flex-row items-center gap-4">
                      <button
                        onClick={handleDirectDownload}
                        disabled={actionStatus === 'loading'}
                        className="flex items-center justify-center gap-2 px-8 py-3.5 rounded-xl bg-gradient-to-r from-blue-900 to-sky-500 hover:from-blue-950 hover:to-sky-600 text-white font-extrabold text-sm shadow-md transition-all cursor-pointer w-full sm:w-auto"
                      >
                        <ArrowDownToLine className="w-4.5 h-4.5 animate-bounce" />
                        Download Android APK (~74MB)
                      </button>

                      <div className="flex items-center gap-1 text-xs text-slate-500 font-semibold">
                        <ShieldCheck className="w-4 h-4 text-emerald-500" />
                        <span>Secure verified APK installer package</span>
                      </div>
                    </div>

                    {actionStatus === 'success' && (
                      <p className="text-xs text-emerald-600 font-bold pl-1">{statusMsg}</p>
                    )}
                  </motion.div>
                )}

              </AnimatePresence>
            </div>

            {/* Badges roadmap */}
            <div className="space-y-3 pt-6 border-t border-slate-200">
              <span className="text-xs font-bold text-slate-400 uppercase tracking-widest block">Coming Soon on Official Stores</span>
              <div className="flex items-center gap-4 opacity-50 hover:opacity-75 transition-opacity">
                {/* Mock Play Store badge */}
                <div className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-900 text-white rounded-lg border border-slate-700">
                  <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                    <path d="M3.609 1.814L13.792 12 3.61 22.186a1.91 1.91 0 01-.61-1.393V3.207c0-.528.22-1.018.61-1.393zM15.207 13.414l3.186-3.186L15.207 7.042l-2.83 2.83 2.83 2.832zm.708-.707l3.889-3.89 1.104 1.105c.488.487.488 1.278 0 1.765l-1.104 1.106-3.889-3.886zm-12.306 9.48l10.183-10.183 2.83 2.83-9.529 9.53a1.91 1.91 0 01-2.915-.093l-1.89-1.92L3.609 22.187z"/>
                  </svg>
                  <div className="text-[8px] font-bold text-left leading-tight">
                    <span>GET IT ON</span>
                    <span className="block text-xs font-black">Google Play</span>
                  </div>
                </div>

                {/* Mock App Store badge */}
                <div className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-900 text-white rounded-lg border border-slate-700">
                  <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.17.67-2.88 1.48-.62.71-1.16 1.85-1.01 2.96 1.11.09 2.24-.57 2.9-1.38z"/>
                  </svg>
                  <div className="text-[8px] font-bold text-left leading-tight">
                    <span>Download on the</span>
                    <span className="block text-xs font-black">App Store</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
