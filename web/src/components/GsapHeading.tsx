'use client';

import React, { useEffect, useLayoutEffect, useRef } from 'react';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

if (typeof window !== 'undefined') {
  gsap.registerPlugin(ScrollTrigger);
}

const useIsomorphicLayoutEffect =
  typeof window !== 'undefined' ? useLayoutEffect : useEffect;

type Props = {
  children: string;
  className?: string;
  as?: 'h1' | 'h2' | 'h3';
  start?: string;
};

/**
 * A heading whose words flip and rise in one-by-one (3D `rotateX` + slide-up +
 * blur, staggered) as it scrolls into view — the same lively reveal as the hero
 * questions, but scroll-triggered and one-shot.
 *
 * Renders `data-gsap-skip` so a wrapping <GsapReveal> leaves it alone (this
 * component owns its own animation). Honors `prefers-reduced-motion`.
 */
export default function GsapHeading({
  children,
  className,
  as: Tag = 'h2',
  start = 'top 85%',
}: Props) {
  const ref = useRef<HTMLHeadingElement>(null);
  // Collapse the surrounding JSX indentation/newlines to clean words.
  const words = children.trim().split(/\s+/);

  useIsomorphicLayoutEffect(() => {
    const el = ref.current;
    if (!el) return;

    const wordEls = el.querySelectorAll<HTMLElement>('.gsap-word');

    const reduceMotion = window.matchMedia?.(
      '(prefers-reduced-motion: reduce)',
    ).matches;
    if (reduceMotion) {
      gsap.set(wordEls, { opacity: 1, yPercent: 0 });
      return;
    }

    const ctx = gsap.context(() => {
      gsap.set(wordEls, { transformOrigin: '50% 100%' });
      gsap.from(wordEls, {
        yPercent: 120,
        opacity: 0,
        rotateX: -90,
        filter: 'blur(10px)',
        duration: 0.8,
        ease: 'back.out(1.6)',
        stagger: 0.07,
        scrollTrigger: { trigger: el, start, once: true },
      });
    }, el);

    return () => ctx.revert();
  }, [children]);

  return (
    <Tag
      ref={ref}
      className={className}
      data-gsap-skip="true"
      style={{ perspective: 800 }}
    >
      {words.map((w, i) => (
        <span
          key={i}
          className="gsap-word inline-block"
          style={{ whiteSpace: 'pre' }}
        >
          {w}
          {i < words.length - 1 ? ' ' : ''}
        </span>
      ))}
    </Tag>
  );
}
