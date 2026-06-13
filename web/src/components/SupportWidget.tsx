'use client';

import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Send, User, Mail, CheckCircle2, Sparkles, AlertCircle } from 'lucide-react';
import { sendSupportMessage } from '../lib/db';
import confetti from 'canvas-confetti';

export default function SupportWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');
  const modalRef = useRef<HTMLDivElement>(null);

  // Listen to the custom event to open the widget
  useEffect(() => {
    const handleOpen = () => {
      setIsOpen(true);
      // Focus name input after animation completes
      setTimeout(() => {
        const nameInput = document.getElementById('support-name-input');
        if (nameInput) nameInput.focus();
      }, 300);
    };

    window.addEventListener('open-support-widget', handleOpen);
    return () => window.removeEventListener('open-support-widget', handleOpen);
  }, []);

  // Close modal when hitting ESC
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        setIsOpen(false);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage('');

    if (!name.trim() || !email.trim() || !message.trim()) {
      setStatus('error');
      setErrorMessage('Please fill in all fields.');
      return;
    }

    // Basic email format check
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setStatus('error');
      setErrorMessage('Please enter a valid email address.');
      return;
    }

    setStatus('loading');

    try {
      // 1. Save message to database/local mock storage
      const res = await sendSupportMessage(name, email, message);

      if (res.success) {
        // Trigger background support email dispatch to confirm receipt and notify admin
        fetch('/api/send-support-message', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name, email, message }),
        }).catch(err => console.error('Background support email dispatch failed:', err));

        setStatus('success');

        // Trigger confetti in the center of the viewport
        confetti({
          particleCount: 80,
          spread: 60,
          origin: { x: 0.5, y: 0.5 },
          colors: ['#0ea5e9', '#6366f1', '#ffffff'],
        });

        // Reset inputs
        setName('');
        setEmail('');
        setMessage('');
      } else {
        setStatus('error');
        setErrorMessage(res.message);
      }
    } catch (err: any) {
      setStatus('error');
      setErrorMessage(err.message || 'An unexpected error occurred.');
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Dark blurred background overlay */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setIsOpen(false)}
            className="absolute inset-0 bg-slate-955/40 backdrop-blur-md"
          />

          {/* Liquid Glass Modal Card */}
          <motion.div
            ref={modalRef}
            initial={{ opacity: 0, scale: 0.9, y: 15 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 15 }}
            transition={{ type: 'spring', damping: 22, stiffness: 280 }}
            className="relative w-full max-w-[460px] rounded-[32px] bg-white/85 border border-white/80 backdrop-blur-xl shadow-[0_24px_50px_-12px_rgba(30,58,138,0.25)] flex flex-col overflow-hidden text-slate-800"
          >
            {/* Colorful Liquid Glow Blobs inside the card glass layer */}
            <div className="absolute -top-20 -left-20 w-56 h-56 bg-sky-450/20 rounded-full blur-[80px] pointer-events-none"></div>
            <div className="absolute -bottom-20 -right-20 w-56 h-56 bg-indigo-500/20 rounded-full blur-[80px] pointer-events-none"></div>

            {/* Glossy Header */}
            <div className="relative p-6 border-b border-white/50 flex justify-between items-center bg-white/50">
              <div className="text-left space-y-1">
                <div className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
                  <h4 className="font-black text-lg text-slate-900 tracking-tight">Support Desk</h4>
                </div>
                <p className="text-xs text-slate-655 font-bold flex items-center gap-1">
                  ClassSync Timetable Support
                </p>
              </div>

              <button
                onClick={() => setIsOpen(false)}
                className="w-8 h-8 rounded-full bg-white/70 hover:bg-white/90 text-slate-700 hover:text-slate-900 flex items-center justify-center transition-colors shadow-sm cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Content / Form Body */}
            <div className="relative p-6 flex-1 overflow-y-auto max-h-[75vh] no-scrollbar">
              {status === 'success' ? (
                /* Success State Screen (No mailto / web-only success) */
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="flex flex-col items-center justify-center text-center py-8 space-y-6"
                >
                  <div className="w-20 h-20 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-600 shadow-inner">
                    <CheckCircle2 className="w-12 h-12 animate-bounce" />
                  </div>
                  
                  <div className="space-y-2">
                    <h5 className="font-black text-slate-950 text-xl tracking-tight font-sans">Message Sent!</h5>
                    <p className="text-sm text-slate-750 font-bold leading-relaxed px-4">
                      Thank you for contacting us. Your support query has been successfully transmitted directly to the ClassSync support desk.
                    </p>
                  </div>

                  <div className="text-xs text-slate-700 font-semibold bg-white/85 border border-white/80 rounded-xl p-3.5 max-w-[340px] shadow-2xs leading-relaxed">
                    A support ticket has been logged inside our portal database. Our support team will review your query and respond to your email address shortly.
                  </div>

                  <button
                    onClick={() => setStatus('idle')}
                    className="w-full py-3.5 rounded-xl bg-gradient-to-r from-sky-500 to-indigo-650 hover:brightness-105 text-white font-extrabold text-xs transition-all flex items-center justify-center gap-1.5 shadow-md hover:shadow-indigo-500/25 active:scale-98 cursor-pointer"
                  >
                    Send Another Message
                  </button>
                </motion.div>
              ) : (
                /* Message Form */
                <form onSubmit={handleSubmit} className="space-y-4 text-left">
                  <p className="text-xs text-slate-755 font-bold leading-relaxed mb-4">
                    Have questions, need schedules import help, or want to report an issue? Fill in your message and we'll reply to your email inbox!
                  </p>

                  {/* Name Input */}
                  <div className="space-y-1.5">
                    <label className="text-[10px] font-black text-slate-755 uppercase tracking-wider pl-0.5">Name</label>
                    <div className="relative">
                      <User className="w-4.5 h-4.5 text-slate-650 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        id="support-name-input"
                        type="text"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        placeholder="Your Name"
                        className="w-full pl-10 pr-4 py-3 rounded-xl bg-white/80 border border-white/90 backdrop-blur-xs text-slate-955 placeholder-slate-500 focus:outline-none focus:border-sky-500/50 focus:bg-white text-xs font-bold transition-all shadow-3xs"
                        disabled={status === 'loading'}
                      />
                    </div>
                  </div>

                  {/* Email Input */}
                  <div className="space-y-1.5">
                    <label className="text-[10px] font-black text-slate-755 uppercase tracking-wider pl-0.5">Email Address</label>
                    <div className="relative">
                      <Mail className="w-4.5 h-4.5 text-slate-655 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="your.email@college.edu"
                        className="w-full pl-10 pr-4 py-3 rounded-xl bg-white/80 border border-white/90 backdrop-blur-xs text-slate-955 placeholder-slate-500 focus:outline-none focus:border-sky-500/50 focus:bg-white text-xs font-bold transition-all shadow-3xs"
                        disabled={status === 'loading'}
                      />
                    </div>
                  </div>

                  {/* Message Box */}
                  <div className="space-y-1.5">
                    <label className="text-[10px] font-black text-slate-755 uppercase tracking-wider pl-0.5">Message Details</label>
                    <textarea
                      value={message}
                      onChange={(e) => setMessage(e.target.value)}
                      placeholder="How can we help? Describe your issue, feedback, or custom schedules suggestion..."
                      rows={4}
                      className="w-full p-3.5 rounded-xl bg-white/80 border border-white/90 backdrop-blur-xs text-slate-955 placeholder-slate-500 focus:outline-none focus:border-sky-500/50 focus:bg-white text-xs font-bold transition-all resize-none shadow-3xs"
                      disabled={status === 'loading'}
                    />
                  </div>

                  {/* Error Display */}
                  {status === 'error' && (
                    <div className="flex items-center gap-2 text-rose-600 text-xs font-semibold bg-rose-500/10 border border-rose-500/20 rounded-xl p-3 shadow-3xs">
                      <AlertCircle className="w-4 h-4 shrink-0" />
                      <span>{errorMessage}</span>
                    </div>
                  )}

                  {/* Submit Button */}
                  <button
                    type="submit"
                    disabled={status === 'loading'}
                    className="w-full py-3.5 mt-2 rounded-xl bg-gradient-to-r from-sky-500 to-indigo-655 hover:brightness-105 disabled:opacity-50 text-white font-extrabold text-xs transition-all flex items-center justify-center gap-1.5 shadow-md hover:shadow-indigo-500/25 active:scale-98 cursor-pointer"
                  >
                    {status === 'loading' ? (
                      <>
                        <span className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                        Sending Message...
                      </>
                    ) : (
                      <>
                        Send Support Message
                        <Send className="w-3.5 h-3.5" />
                      </>
                    )}
                  </button>
                </form>
              )}
            </div>

            {/* Glossy Footer Bar */}
            <div className="p-4 border-t border-white/50 text-[10px] text-slate-650 font-bold bg-white/45 text-center">
              ClassSync Portal &copy; {new Date().getFullYear()} Support System
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
