'use client';

import React, { useEffect, useLayoutEffect, useRef } from 'react';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

if (typeof window !== 'undefined') {
  gsap.registerPlugin(ScrollTrigger);
}

// Layout effect on the client (set the from-state before paint, no flash),
// useEffect during SSR to avoid React's warning.
const useIsomorphicLayoutEffect =
  typeof window !== 'undefined' ? useLayoutEffect : useEffect;

type Props = {
  children: React.ReactNode;
  className?: string;
  /** Distance (px) the items rise from. */
  y?: number;
  duration?: number;
  /** Delay between each direct child animating in. */
  stagger?: number;
  delay?: number;
  /** ScrollTrigger start position. */
  start?: string;
};

/**
 * Reveals its direct children with a staggered GSAP fade + slide-up as the block
 * scrolls into view. Drop-in replacement for a wrapping `<div>` — keep the same
 * className and the layout is unchanged, the text just animates in on scroll.
 *
 * Honors `prefers-reduced-motion` (renders fully visible, no movement).
 */
export default function GsapReveal({
  children,
  className,
  y = 26,
  duration = 0.7,
  stagger = 0.12,
  delay = 0,
  start = 'top 85%',
}: Props) {
  const ref = useRef<HTMLDivElement>(null);

  useIsomorphicLayoutEffect(() => {
    const el = ref.current;
    if (!el) return;

    // Animate direct children, but skip any that run their own animation
    // (e.g. a <GsapHeading> word-cascade) so we don't double-animate them.
    const all = el.children.length ? Array.from(el.children) : [el];
    const targets = all.filter(
      (c) => !(c as HTMLElement).hasAttribute('data-gsap-skip'),
    );
    if (targets.length === 0) return;

    const reduceMotion = window.matchMedia?.(
      '(prefers-reduced-motion: reduce)',
    ).matches;
    if (reduceMotion) {
      gsap.set(targets, { opacity: 1, y: 0 });
      return;
    }

    const ctx = gsap.context(() => {
      gsap.fromTo(
        targets,
        { opacity: 0, y, scale: 0.96, filter: 'blur(6px)' },
        {
          opacity: 1,
          y: 0,
          scale: 1,
          filter: 'blur(0px)',
          duration,
          delay,
          ease: 'power3.out',
          stagger,
          scrollTrigger: { trigger: el, start, once: true },
        },
      );
    }, el);

    return () => ctx.revert();
  }, []);

  return (
    <div ref={ref} className={className}>
      {children}
    </div>
  );
}
