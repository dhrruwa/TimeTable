'use client';

import React, { useState, useEffect, useLayoutEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { gsap } from 'gsap';
import { Clock } from 'lucide-react';

// useLayoutEffect on the client (so words are positioned before paint, no
// flash), but fall back to useEffect during SSR to avoid React's warning.
const useIsomorphicLayoutEffect =
  typeof window !== 'undefined' ? useLayoutEffect : useEffect;

const GRADIENT =
  'bg-gradient-to-r from-sky-500 via-sky-600 to-indigo-600 bg-clip-text text-transparent font-extrabold';

// Each question is a list of segments; `hl` segments get the gradient. Storing
// them as data (rather than JSX) lets us split into per-word spans for GSAP.
type Segment = { text: string; hl?: boolean };

const QUESTIONS: Segment[][] = [
  [{ text: 'What ' }, { text: 'class', hl: true }, { text: ' is running right now?' }],
  [{ text: 'What is your ' }, { text: 'next period', hl: true }, { text: '?' }],
  [{ text: 'Which subject do you have ' }, { text: 'tomorrow morning', hl: true }, { text: '?' }],
  [{ text: 'How much of today’s classes are ' }, { text: 'already completed', hl: true }, { text: '?' }],
  [{ text: 'Are you sure your attendance percentage is ' }, { text: 'safe', hl: true }, { text: '?' }],
];

// Flatten a question into word tokens (keeping the surrounding whitespace) so
// each word can be a single inline-block GSAP target.
function toWords(segments: Segment[]): { token: string; hl: boolean }[] {
  const words: { token: string; hl: boolean }[] = [];
  for (const seg of segments) {
    const tokens = seg.text.match(/\s*\S+\s*/g) ?? [];
    for (const token of tokens) words.push({ token, hl: !!seg.hl });
  }
  return words;
}

export default function HeroSection() {
  const [currentQuestionIdx, setCurrentQuestionIdx] = useState(0);
  const [time, setTime] = useState<string>('09:00:00 AM');
  const audioContextRef = useRef<AudioContext | null>(null);
  const isFirstQuestionRef = useRef(true);
  const heroRef = useRef<HTMLElement | null>(null);
  const isHeroVisibleRef = useRef(true);
  const headlineRef = useRef<HTMLHeadingElement | null>(null);
  
  // Live clock updater
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }));
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  // GSAP word-cascade: for each question the words flip/slide IN with a stagger,
  // hold, then fly OUT — and on completion we advance to the next question,
  // which re-runs this effect for a seamless loop.
  useIsomorphicLayoutEffect(() => {
    const headline = headlineRef.current;
    if (!headline) return;

    const words = gsap.utils.toArray<HTMLElement>('.hero-word', headline);
    const next = () =>
      setCurrentQuestionIdx((prev) => (prev + 1) % QUESTIONS.length);

    const reduceMotion =
      window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;

    if (reduceMotion || words.length === 0) {
      // Honor reduced-motion: no movement, just hold and advance.
      const hold = window.setTimeout(next, 3200);
      return () => window.clearTimeout(hold);
    }

    const ctx = gsap.context(() => {
      gsap.set(words, { transformOrigin: '50% 100%' });
      const tl = gsap.timeline({ onComplete: next });
      tl.from(words, {
        yPercent: 120,
        opacity: 0,
        rotateX: -90,
        filter: 'blur(8px)',
        duration: 0.7,
        ease: 'back.out(1.5)',
        stagger: 0.05,
      });
      tl.to(
        words,
        {
          yPercent: -120,
          opacity: 0,
          rotateX: 90,
          filter: 'blur(8px)',
          duration: 0.45,
          ease: 'power2.in',
          stagger: 0.03,
        },
        '+=2.1', // hold the fully-revealed question before it leaves
      );
    }, headline);

    return () => ctx.revert();
  }, [currentQuestionIdx]);

  useEffect(() => {
    const hero = heroRef.current;
    if (!hero) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        isHeroVisibleRef.current = entry.isIntersecting;
      },
      { threshold: 0.2 },
    );

    observer.observe(hero);
    return () => observer.disconnect();
  }, []);

  // Browsers allow page audio after the visitor's first interaction.
  useEffect(() => {
    const enableAudio = () => {
      if (!audioContextRef.current) {
        audioContextRef.current = new AudioContext();
      }
      void audioContextRef.current.resume();
    };

    window.addEventListener('pointerdown', enableAudio, { once: true });
    window.addEventListener('keydown', enableAudio, { once: true });

    return () => {
      window.removeEventListener('pointerdown', enableAudio);
      window.removeEventListener('keydown', enableAudio);
      const audioContext = audioContextRef.current;
      audioContextRef.current = null;
      void audioContext?.close();
    };
  }, []);

  useEffect(() => {
    if (isFirstQuestionRef.current) {
      isFirstQuestionRef.current = false;
      return;
    }

    if (!isHeroVisibleRef.current) return;

    const audioContext = audioContextRef.current;
    if (!audioContext || audioContext.state !== 'running') return;

    const now = audioContext.currentTime;
    const duration = 0.75;
    const sampleCount = Math.ceil(audioContext.sampleRate * duration);
    const noiseBuffer = audioContext.createBuffer(1, sampleCount, audioContext.sampleRate);
    const noiseData = noiseBuffer.getChannelData(0);

    for (let i = 0; i < sampleCount; i++) {
      const progress = i / sampleCount;
      noiseData[i] = (Math.random() * 2 - 1) * Math.sin(Math.PI * progress);
    }

    const noise = audioContext.createBufferSource();
    const filter = audioContext.createBiquadFilter();
    const whooshGain = audioContext.createGain();
    const impact = audioContext.createOscillator();
    const impactGain = audioContext.createGain();

    noise.buffer = noiseBuffer;
    filter.type = 'bandpass';
    filter.Q.setValueAtTime(0.8, now);
    filter.frequency.setValueAtTime(250, now);
    filter.frequency.exponentialRampToValueAtTime(4200, now + 0.48);
    filter.frequency.exponentialRampToValueAtTime(900, now + duration);
    whooshGain.gain.setValueAtTime(0.0001, now);
    whooshGain.gain.exponentialRampToValueAtTime(0.18, now + 0.35);
    whooshGain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

    impact.type = 'sine';
    impact.frequency.setValueAtTime(100, now + 0.34);
    impact.frequency.exponentialRampToValueAtTime(48, now + 0.68);
    impactGain.gain.setValueAtTime(0.0001, now);
    impactGain.gain.setValueAtTime(0.12, now + 0.34);
    impactGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.7);

    noise.connect(filter);
    filter.connect(whooshGain);
    whooshGain.connect(audioContext.destination);
    impact.connect(impactGain);
    impactGain.connect(audioContext.destination);

    noise.addEventListener('ended', () => {
      noise.disconnect();
      filter.disconnect();
      whooshGain.disconnect();
      impact.disconnect();
      impactGain.disconnect();
    }, { once: true });

    noise.start(now);
    noise.stop(now + duration);
    impact.start(now);
    impact.stop(now + duration);
  }, [currentQuestionIdx]);

  return (
    <section ref={heroRef} className="relative min-h-[98vh] sm:min-h-[101vh] lg:min-h-[104vh] flex flex-col items-center justify-center pt-32 pb-24 px-4 overflow-hidden bg-transparent">
      {/* Background patterns: Premium clean grids & liquid layout elements */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,rgba(14,165,233,0.015)_1px,transparent_1px),linear-gradient(to_bottom,rgba(14,165,233,0.015)_1px,transparent_1px)] bg-[size:3.5rem_3.5rem] z-0"></div>
      
      {/* Glowing backdrops */}
      <div className="absolute top-1/4 left-1/3 -translate-x-1/2 bg-sky-400/8 w-[500px] h-[250px] rounded-full blur-[100px] z-0"></div>
      <div className="absolute bottom-1/4 right-1/4 bg-blue-900/8 w-[400px] h-[200px] rounded-full blur-[120px] z-0"></div>

      {/* Floating Animated Timetable Elements */}
      <div className="absolute inset-0 pointer-events-none hidden lg:block overflow-hidden z-10">
        
        {/* Floating Card 1: Subject Period Indicator */}
        <motion.div 
          className="absolute top-[22%] left-[8%] w-[250px] p-4 rounded-2xl glass shadow-md border border-slate-200/80 animate-float"
        >
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Ongoing Period</span>
          </div>
          <h4 className="text-sm font-extrabold text-slate-800">Advanced CSE Seminar</h4>
          <p className="text-xs text-slate-500 font-semibold mt-0.5">Room 402B · Prof. Watson</p>
          <div className="w-full bg-slate-100 rounded-full h-1.5 mt-3 overflow-hidden">
            <div className="bg-sky-500 h-1.5 rounded-full w-[65%]"></div>
          </div>
          <div className="flex justify-between items-center text-[9px] text-slate-400 font-bold mt-2">
            <span>65% completed</span>
            <span>15 mins left</span>
          </div>
        </motion.div>

        {/* Floating Card 2: Live Clock Widget */}
        <motion.div 
          className="absolute top-[35%] right-[7%] w-[220px] p-4 rounded-2xl glass shadow-md border border-slate-200/80 animate-float-delayed flex items-center gap-3.5"
        >
          <div className="w-10 h-10 rounded-xl bg-sky-50 flex items-center justify-center text-sky-500 shrink-0">
            <Clock className="w-5 h-5" />
          </div>
          <div className="text-left">
            <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest block">ClassSync Clock</span>
            <span className="text-sm font-black text-slate-800 font-mono tracking-tight block mt-0.5">{time}</span>
            <span className="text-[9px] text-sky-600 font-semibold block">In sync with university hub</span>
          </div>
        </motion.div>

        {/* Floating Card 3: Attendance tracker widget */}
        <motion.div 
          className="absolute bottom-[20%] left-[10%] w-[190px] p-3.5 rounded-2xl glass shadow-md border border-slate-200/80 animate-float-delayed"
        >
          <div className="flex items-center justify-between mb-2">
            <span className="text-[10px] font-extrabold text-slate-700 uppercase tracking-wider">Attendance Rate</span>
            <span className="px-1.5 py-0.5 bg-emerald-50 text-[8px] font-black text-emerald-600 border border-emerald-100 rounded">
              SAFE
            </span>
          </div>
          <div className="flex items-baseline gap-1">
            <span className="text-xl font-black text-slate-900">82.4%</span>
            <span className="text-[9px] text-slate-400 font-semibold">Overall</span>
          </div>
          <p className="text-[9.5px] text-slate-500 font-medium mt-1">Next: Math class attendance is critical</p>
        </motion.div>

      </div>

      <div className="max-w-5xl mx-auto text-center space-y-10 relative z-20 w-full">
        {/* Dynamic Sliding Headline Questions (Centered, Relative normal-flow rendering to fix spacing) */}
        <div 
          className="h-[315px] sm:h-[386px] md:h-[443px] lg:h-[386px] flex items-center justify-center overflow-hidden relative w-full"
          style={{ perspective: 1200 }}
        >
          <h1
            ref={headlineRef}
            key={currentQuestionIdx}
            style={{ transformStyle: 'preserve-3d' }}
            className="w-full max-w-4xl px-4 text-center text-[47px] sm:text-[62px] md:text-[78px] lg:text-[94px] font-extrabold text-slate-900 tracking-tight leading-snug select-none"
          >
            {toWords(QUESTIONS[currentQuestionIdx]).map((w, i) => (
              <span
                key={i}
                className={`hero-word inline-block ${w.hl ? GRADIENT : ''}`}
                style={{ whiteSpace: 'pre' }}
              >
                {w.token}
              </span>
            ))}
          </h1>
        </div>

        {/* Static Marketing Subheadline */}
        <div className="space-y-4 pt-2">
          <motion.p 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="text-sm sm:text-base md:text-lg text-slate-900 font-medium max-w-3xl mx-auto leading-relaxed px-4"
          >
            Know your current class, upcoming lectures, attendance percentage, daily progress, and complete timetable instantly. All in one place.
          </motion.p>
        </div>
      </div>
    </section>
  );
}
