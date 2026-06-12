'use client';

import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Mail, Sparkles, ArrowRight, CheckCircle2, User } from 'lucide-react';
import { subscribeNewsletter } from '../lib/db';
import confetti from 'canvas-confetti';

export default function NewsletterSection() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [message, setMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !email.trim()) {
      setStatus('error');
      setMessage('Please fill in all fields.');
      return;
    }

    setStatus('loading');
    try {
      const res = await subscribeNewsletter(name, email);
      if (res.success) {
        setStatus('success');
        setMessage(res.message);
        setName('');
        setEmail('');
        // Trigger small confetti
        confetti({
          particleCount: 80,
          spread: 50,
          origin: { y: 0.8 },
          colors: ['#0ea5e9', '#38bdf8', '#ffffff'],
        });
      } else {
        setStatus('error');
        setMessage(res.message);
      }
    } catch (err: any) {
      setStatus('error');
      setMessage(err.message || 'Something went wrong.');
    }
  };

  return (
    <section id="newsletter" className="relative py-24 bg-white overflow-hidden border-t border-slate-100">
      {/* Decorative backdrop glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-indigo-50/10 rounded-full blur-[120px] pointer-events-none"></div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
        
        {/* Glow Container */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="glass p-8 sm:p-12 rounded-[28px] border border-slate-200 bg-gradient-to-tr from-slate-50/50 via-white to-sky-50/20 shadow-2xl relative overflow-hidden"
        >
          <div className="max-w-lg mx-auto space-y-6">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-sky-50 border border-sky-200 text-sky-600 text-xs font-bold uppercase tracking-wider">
              <Sparkles className="w-3.5 h-3.5 text-sky-500" /> Early Access
            </span>

            <h3 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              Join The Early Access List
            </h3>

            <p className="text-slate-600 text-sm sm:text-base leading-relaxed">
              Be the first to know when ClassSync launches officially on the Google Play Store and Apple App Store. Get updates, beta releases, and tips.
            </p>

            {status === 'success' ? (
              <motion.div 
                initial={{ scale: 0.95, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                className="p-6 rounded-2xl bg-emerald-50 border border-emerald-250 text-emerald-700 flex flex-col items-center gap-2"
              >
                <CheckCircle2 className="w-8 h-8 text-emerald-500" />
                <p className="font-bold text-sm">{message}</p>
                <p className="text-xs text-slate-500 mt-1 font-medium">Thank you for joining our student list!</p>
                <button
                  onClick={() => setStatus('idle')}
                  className="mt-3 text-xs text-sky-500 font-extrabold hover:underline cursor-pointer"
                >
                  Register another email
                </button>
              </motion.div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4 text-left">
                {/* Name field */}
                <div className="relative">
                  <User className="w-4.5 h-4.5 text-slate-400 absolute left-4.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Enter your name"
                    className="w-full pl-12 pr-4 py-3.5 rounded-xl bg-white border border-slate-200 text-slate-800 placeholder-slate-400 focus:outline-none focus:border-sky-500/50 focus:ring-1 focus:ring-sky-500/50 text-sm transition-all shadow-2xs"
                    disabled={status === 'loading'}
                  />
                </div>

                {/* Email field */}
                <div className="relative">
                  <Mail className="w-4.5 h-4.5 text-slate-400 absolute left-4.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Enter your email address"
                    className="w-full pl-12 pr-4 py-3.5 rounded-xl bg-white border border-slate-200 text-slate-800 placeholder-slate-400 focus:outline-none focus:border-sky-500/50 focus:ring-1 focus:ring-sky-500/50 text-sm transition-all shadow-2xs"
                    disabled={status === 'loading'}
                  />
                </div>

                {/* Status messages */}
                {status === 'error' && (
                  <p className="text-xs text-rose-500 font-medium pl-1">{message}</p>
                )}

                {/* Submit button */}
                <button
                  type="submit"
                  disabled={status === 'loading'}
                  className="w-full py-3.5 rounded-xl bg-sky-500 hover:bg-sky-600 disabled:opacity-50 text-white font-bold text-sm transition-all duration-300 hover:shadow-lg hover:shadow-sky-500/25 flex items-center justify-center gap-1.5 active:scale-98 cursor-pointer"
                >
                  {status === 'loading' ? (
                    <>
                      <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                      Registering...
                    </>
                  ) : (
                    <>
                      Secure Early Access
                      <ArrowRight className="w-4 h-4" />
                    </>
                  )}
                </button>
              </form>
            )}
            
            <p className="text-[10px] text-slate-400 mt-2 font-medium">
              *We respect your privacy. No spam. Unsubscribe at any time.
            </p>
          </div>
        </motion.div>

      </div>
    </section>
  );
}
