import React from 'react';
import Navbar from '../components/Navbar';
import HeroSection from '../components/HeroSection';
import FeaturesSection from '../components/FeaturesSection';
import ProblemSection from '../components/ProblemSection';
import SolutionSection from '../components/SolutionSection';
import TimelineSection from '../components/TimelineSection';
import ShowcaseSection from '../components/ShowcaseSection';
import CollegesGrid from '../components/CollegesGrid';
import StatsSection from '../components/StatsSection';
import DownloadSection from '../components/DownloadSection';
import TestimonialsSection from '../components/TestimonialsSection';
import FaqSection from '../components/FaqSection';
import Footer from '../components/Footer';
import CursorGlow from '../components/CursorGlow';

export default function Home() {
  return (
    <div className="relative min-h-screen flex flex-col overflow-hidden bg-gradient-to-tr from-blue-50 via-white to-sky-100/70">
      {/* Background animations & cursor spotlight */}
      <CursorGlow />

      {/* Background liquid blur circle */}
      <div className="absolute top-[10%] left-[-10%] w-[50vw] h-[50vw] rounded-full bg-gradient-to-tr from-blue-900/5 to-transparent blur-[120px] pointer-events-none z-0"></div>
      <div className="absolute bottom-[20%] right-[-10%] w-[45vw] h-[45vw] rounded-full bg-gradient-to-bl from-sky-500/5 to-transparent blur-[100px] pointer-events-none z-0"></div>

      {/* Main Layout */}
      <Navbar />
      
      <main className="flex-1 relative z-10">
        <HeroSection />
        <FeaturesSection />
        <ProblemSection />
        <SolutionSection />
        <TimelineSection />
        <ShowcaseSection />
        <CollegesGrid />
        <StatsSection />
        <DownloadSection />
        <TestimonialsSection />
        <FaqSection />
      </main>

      <Footer />
    </div>
  );
}
