// Shared helpers for the Little Explorers support API.
export const TOPICS = [
  'Subscription and billing',
  'Using the app',
  'Something is not working',
  'Privacy and data',
  'Learning content',
  'Other',
];
export const PLATFORMS = ['iPhone', 'iPad', 'Android phone', 'Android tablet', 'Other', ''];
const ALLOWED_ORIGINS = ['https://little-explorers-app.pages.dev', 'https://stephenmwangi40.github.io'];

export function cors(request) {
  const origin = request.headers.get('origin') || '';
  const ok = ALLOWED_ORIGINS.includes(origin) || /^https:\/\/[a-z0-9-]+\.little-explorers-app\.pages\.dev$/.test(origin);
  return ok
    ? {
        'access-control-allow-origin': origin,
        'access-control-allow-methods': 'GET, POST, OPTIONS',
        'access-control-allow-headers': 'content-type, x-ticket-code',
        'access-control-max-age': '86400',
        vary: 'origin',
      }
    : {};
}

export function json(request, data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
      'x-content-type-options': 'nosniff',
      ...cors(request),
    },
  });
}

export const now = () => Math.floor(Date.now() / 1000);

export async function sha256(text) {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0, O, 1 or I
export function randomCode(len) {
  const bytes = crypto.getRandomValues(new Uint8Array(len));
  return [...bytes].map((b) => ALPHABET[b % ALPHABET.length]).join('');
}

// Constant-time string comparison.
export function safeEqual(a, b) {
  const x = new TextEncoder().encode(a || '');
  const y = new TextEncoder().encode(b || '');
  let diff = x.length ^ y.length;
  for (let i = 0; i < Math.max(x.length, y.length); i++) diff |= (x[i] || 0) ^ (y[i] || 0);
  return diff === 0;
}

// Simple rate limiting with a hashed IP address that is kept for 1 day.
export async function limited(env, request, bucket, max, windowSecs) {
  const ip = request.headers.get('cf-connecting-ip') || 'unknown';
  const day = new Date().toISOString().slice(0, 10);
  const key = bucket + ':' + (await sha256(ip + '|' + day)).slice(0, 32);
  const t = now();
  await env.DB.prepare('DELETE FROM rate WHERE at < ?').bind(t - 86400).run();
  const row = await env.DB.prepare('SELECT COUNT(*) AS n FROM rate WHERE key = ? AND at > ?').bind(key, t - windowSecs).first();
  if ((row?.n || 0) >= max) return true;
  await env.DB.prepare('INSERT INTO rate (key, at) VALUES (?, ?)').bind(key, t).run();
  return false;
}

export function clean(text, max) {
  return String(text || '')
    .replace(/\r\n/g, '\n')
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, '')
    .trim()
    .slice(0, max);
}

export async function thread(env, id) {
  const { results } = await env.DB.prepare(
    'SELECT author, body, created_at FROM messages WHERE ticket_id = ? ORDER BY created_at, id',
  )
    .bind(id)
    .all();
  return results;
}
