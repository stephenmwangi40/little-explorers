import { clean, json, limited, now, sha256, thread } from '../../_lib.js';

async function load(env, request, params) {
  const id = String(params.id || '').toUpperCase();
  const code = (request.headers.get('x-ticket-code') || '').toUpperCase().trim();
  if (!/^LE-[A-Z0-9]{6}$/.test(id) || !/^[A-Z0-9]{8}$/.test(code)) return null;
  if (await limited(env, request, 'lookup', 60, 3600)) return 'limited';
  const t = await env.DB.prepare('SELECT * FROM tickets WHERE id = ?').bind(id).first();
  if (!t || t.code_hash !== (await sha256(code))) return null;
  return t;
}

// GET /api/tickets/:id (header x-ticket-code): a parent checks for a reply.
export async function onRequestGet({ request, env, params }) {
  const t = await load(env, request, params);
  if (t === 'limited') return json(request, { error: 'Too many tries. Please wait an hour.' }, 429);
  if (!t) return json(request, { error: 'We could not find that request. Check the request number and code.' }, 404);
  return json(request, { id: t.id, topic: t.topic, status: t.status, created_at: t.created_at, messages: await thread(env, t.id) });
}

// POST /api/tickets/:id: a parent adds a follow-up message.
export async function onRequestPost({ request, env, params }) {
  const t = await load(env, request, params);
  if (t === 'limited') return json(request, { error: 'Too many tries. Please wait an hour.' }, 429);
  if (!t) return json(request, { error: 'We could not find that request.' }, 404);
  let body;
  try {
    body = await request.json();
  } catch {
    return json(request, { error: 'Please try again.' }, 400);
  }
  const message = clean(body.message, 2000);
  if (message.length < 2) return json(request, { error: 'Please write a message.' }, 400);
  if (await limited(env, request, 'reply', 20, 3600)) return json(request, { error: 'Too many messages. Please wait an hour.' }, 429);
  const ts = now();
  await env.DB.batch([
    env.DB.prepare('INSERT INTO messages (ticket_id, author, body, created_at) VALUES (?, ?, ?, ?)').bind(t.id, 'parent', message, ts),
    env.DB.prepare("UPDATE tickets SET status = 'open', updated_at = ?, unread_admin = 1 WHERE id = ?").bind(ts, t.id),
  ]);
  return json(request, { ok: true, status: 'open', messages: await thread(env, t.id) });
}
