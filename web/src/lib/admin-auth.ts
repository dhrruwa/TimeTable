import crypto from 'crypto';

/**
 * Admin session auth — secure by construction.
 *
 * - No hardcoded password. If ADMIN_PASSWORD is unset the admin is locked
 *   (fail closed) instead of falling back to a default that lives in the
 *   (public) repo.
 * - The session cookie is an HMAC-SIGNED, self-expiring token — NOT a static
 *   hash of the password. It can't be forged without the server secret and it
 *   stops being valid after the TTL, so a leaked/old cookie can't be replayed.
 * - All secret comparisons are constant-time.
 */

export const ADMIN_COOKIE = 'classsync_admin_session';
const SESSION_TTL_SECONDS = 60 * 60 * 2; // 2 hours

/** The configured admin password, or null when the server isn't set up. */
export function getAdminPassword(): string | null {
  const pw = process.env.ADMIN_PASSWORD;
  return pw && pw.trim().length > 0 ? pw : null;
}

/** Server-only key used to sign session tokens (never sent to the client). */
function sessionSecret(): string {
  // Prefer a dedicated secret; otherwise sign with the admin password so a
  // single configured env var still yields unforgeable tokens.
  return process.env.ADMIN_SESSION_SECRET || process.env.ADMIN_PASSWORD || '';
}

function sign(value: string): string {
  return crypto.createHmac('sha256', sessionSecret()).update(value).digest('hex');
}

/** Constant-time comparison that won't throw on length mismatch. */
export function safeEqual(a: string, b: string): boolean {
  const ba = Buffer.from(a, 'utf8');
  const bb = Buffer.from(b, 'utf8');
  if (ba.length !== bb.length) return false;
  return crypto.timingSafeEqual(ba, bb);
}

/** Check a submitted password against the configured one (constant-time). */
export function passwordMatches(submitted: unknown): boolean {
  const expected = getAdminPassword();
  if (!expected || typeof submitted !== 'string') return false;
  return safeEqual(submitted, expected);
}

/** Mint a signed, self-expiring session token + its cookie maxAge. */
export function createSessionToken(): { value: string; maxAge: number } {
  const exp = Date.now() + SESSION_TTL_SECONDS * 1000;
  const payload = String(exp);
  return { value: `${payload}.${sign(payload)}`, maxAge: SESSION_TTL_SECONDS };
}

/** True only if the token is correctly signed AND not expired. */
export function isValidSessionToken(token: string | undefined): boolean {
  if (!token || !sessionSecret()) return false;
  const dot = token.lastIndexOf('.');
  if (dot < 0) return false;
  const payload = token.slice(0, dot);
  const sig = token.slice(dot + 1);
  if (!safeEqual(sig, sign(payload))) return false;
  const exp = Number(payload);
  return Number.isFinite(exp) && exp > Date.now();
}
