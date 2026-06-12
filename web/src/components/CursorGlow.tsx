'use client';

import React, { useEffect } from 'react';
import { motion, useMotionValue, useSpring, useTransform } from 'framer-motion';

export default function CursorGlow() {
  const mouseX = useMotionValue(-1000);
  const mouseY = useMotionValue(-1000);

  // Smooth spring physics for cursor follow
  const springX = useSpring(mouseX, { stiffness: 90, damping: 24 });
  const springY = useSpring(mouseY, { stiffness: 90, damping: 24 });

  // Map to values with 'px' suffix to satisfy CSS gradient syntax
  const pxX = useTransform(springX, (val) => `${val}px`);
  const pxY = useTransform(springY, (val) => `${val}px`);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      mouseX.set(e.clientX);
      mouseY.set(e.clientY);
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
    };
  }, [mouseX, mouseY]);

  return (
    <div className="fixed inset-0 pointer-events-none z-0 overflow-hidden select-none">
      {/* 1. Dynamic Cursor Spotlight (White Glow) */}
      <motion.div
        className="absolute inset-0 z-[1] opacity-75"
        style={{
          background: `radial-gradient(380px circle at var(--x) var(--y), rgba(255, 255, 255, 0.95), transparent 85%)`,
          ['--x' as any]: pxX,
          ['--y' as any]: pxY,
        }}
      />

      {/* 2. Floating Background Dynamic Blobs */}
      {/* Blob A - Top Left */}
      <motion.div
        animate={{
          x: [0, 50, -30, 0],
          y: [0, -60, 40, 0],
          scale: [1, 1.15, 0.95, 1],
        }}
        transition={{
          duration: 22,
          repeat: Infinity,
          ease: "easeInOut"
        }}
        className="absolute top-[10%] left-[5%] w-[450px] h-[450px] rounded-full bg-blue-400/8 blur-[110px]"
      />

      {/* Blob B - Middle Right */}
      <motion.div
        animate={{
          x: [0, -70, 50, 0],
          y: [0, 90, -50, 0],
          scale: [1, 0.9, 1.12, 1],
        }}
        transition={{
          duration: 28,
          repeat: Infinity,
          ease: "easeInOut"
        }}
        className="absolute top-[35%] right-[5%] w-[550px] h-[550px] rounded-full bg-sky-400/8 blur-[130px]"
      />

      {/* Blob C - Bottom Left */}
      <motion.div
        animate={{
          x: [0, 60, -40, 0],
          y: [0, -50, 70, 0],
          scale: [1, 1.1, 0.9, 1],
        }}
        transition={{
          duration: 25,
          repeat: Infinity,
          ease: "easeInOut"
        }}
        className="absolute bottom-[15%] left-[8%] w-[420px] h-[420px] rounded-full bg-indigo-400/8 blur-[95px]"
      />
    </div>
  );
}
