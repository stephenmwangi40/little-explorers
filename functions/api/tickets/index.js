import { PLATFORMS, TOPICS, clean, json, limited, now, randomCode, sha256 } from '../../_lib.js';

// POST /api/tickets: a parent opens a support request.
export async function onRequestPost({ request, env }) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json(request, { error: 'Please send the form again.' }, 400);
  }
  if (body.website) return json(request, { error: 'Please send the form again.' }, 400); // spam trap
  const topic = clean(body.topic, 60);
  const platform = clean(body.platform, 30);
  const version = clean(body.appVersion, 20);
  const message = clean(body.message, 2000);
  if (!TOPICS.includes(topic)) return json(request, { error: 'Please choose a topic.' }, 400);
  if (!PLATFORMS.includes(platform)) return json(request, { error: 'Please choose a device.' }, 400);
  if (message.length < 10) return json(request, { error: 'Please tell us a little more (at least 10 characters).' }, 400);
  if (await limited(env, request, 'new', 5, 3600)) {
    return json(request, { error: 'Too many requests. Please try again in an hour.' }, 429);
  }
  const id = 'LE-' + randomCode(6);
  const code = randomCode(8);
  const t = now();
  await env.DB.batch([
    env.DB.prepare(
      'INSERT INTO tickets (id, code_hash, topic, platform, app_version, status, created_at, updated_at, unread_admin) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)',
    ).bind(id, await sha256(code), topic, platform, version, 'open', t, t),
    env.DB.prepare('INSERT INTO messages (ticket_id, author, body, created_at) VALUES (?, ?, ?, ?)').bind(id, 'parent', message, t),
  ]);
  return json(request, { id, code }, 201);
}
