// Input hardening + a best-effort per-IP rate limiter for the public email
// endpoints, so they can't be used to spam/bomb arbitrary addresses from our
// domain or inject HTML into the outgoing mail.
//
// The limiter is in-memory (per serverless instance) — a strong first line of
// defense; pair with a platform WAF / KV store for hard guarantees at scale.

const _hits = new Map<string, number[]>();

/** Returns false when [key] has exceeded [max] requests within [windowMs]. */
export function rateLimit(key: string, max: number, windowMs: number): boolean {
  const now = Date.now();
  const recent = (_hits.get(key) ?? []).filter((t) => now - t < windowMs);
  if (recent.length >= max) {
    _hits.set(key, recent);
    return false;
  }
  recent.push(now);
  _hits.set(key, recent);
  // Opportunistic cleanup so the map can't grow unbounded.
  if (_hits.size > 5000) {
    for (const [k, v] of _hits) {
      if (v.every((t) => now - t >= windowMs)) _hits.delete(k);
    }
  }
  return true;
}

/** Best-effort client IP from proxy headers. */
export function clientIp(req: Request): string {
  const h = req.headers;
  return (
    h.get('x-forwarded-for')?.split(',')[0]?.trim() ||
    h.get('x-real-ip') ||
    'unknown'
  );
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/** RFC-ish email sanity check with a length cap. */
export function isValidEmail(email: unknown): email is string {
  return (
    typeof email === 'string' &&
    email.length <= 254 &&
    EMAIL_RE.test(email)
  );
}

/** Escapes user input before interpolating it into an HTML email body. */
export function escapeHtml(s: unknown): string {
  return String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/** Trims to a hard max length (defends against oversized payloads). */
export function clampText(s: unknown, max: number): string {
  return String(s ?? '').slice(0, max);
}
