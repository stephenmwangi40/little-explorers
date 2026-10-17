import { clean, json, now, thread } from '../../../_lib.js';

async function ticket(env, id) {
  return env.DB.prepare('SELECT id, topic, platform, app_version, status, created_at, updated_at FROM tickets WHERE id = ?')
    .bind(String(id || '').toUpperCase())
    .first();
}

// GET /api/admin/tickets/:id: the full conversation (marks it read).
export async function onRequestGet({ request, env, params }) {
  const t = await ticket(env, params.id);
  if (!t) return json(request, { error: 'Not found.' }, 404);
  await env.DB.prepare('UPDATE tickets SET unread_admin = 0 WHERE id = ?').bind(t.id).run();
  return json(request, { ...t, messages: await thread(env, t.id) });
}

// POST /api/admin/tickets/:id  {action: 'reply' | 'close' | 'reopen' | 'delete', message?}
export async function onRequestPost({ request, env, params }) {
  const t = await ticket(env, params.id);
  if (!t) return json(request, { error: 'Not found.' }, 404);
  let body;
  try {
    body = await request.json();
  } catch {
    return json(request, { error: 'Bad request.' }, 400);
  }
  const ts = now();
  switch (body.action) {
    case 'reply': {
      const message = clean(body.message, 4000);
      if (message.length < 2) return json(request, { error: 'Please write a reply.' }, 400);
      await env.DB.batch([
        env.DB.prepare('INSERT INTO messages (ticket_id, author, body, created_at) VALUES (?, ?, ?, ?)').bind(t.id, 'support', message, ts),
        env.DB.prepare("UPDATE tickets SET status = 'answered', updated_at = ?, unread_admin = 0 WHERE id = ?").bind(ts, t.id),
      ]);
      break;
    }
    case 'close':
      await env.DB.prepare("UPDATE tickets SET status = 'closed', updated_at = ? WHERE id = ?").bind(ts, t.id).run();
      break;
    case 'reopen':
      await env.DB.prepare("UPDATE tickets SET status = 'open', updated_at = ? WHERE id = ?").bind(ts, t.id).run();
      break;
    case 'delete':
      await env.DB.batch([
        env.DB.prepare('DELETE FROM messages WHERE ticket_id = ?').bind(t.id),
        env.DB.prepare('DELETE FROM tickets WHERE id = ?').bind(t.id),
      ]);
      return json(request, { ok: true, deleted: true });
    default:
      return json(request, { error: 'Unknown action.' }, 400);
  }
  return json(request, { ...(await ticket(env, t.id)), messages: await thread(env, t.id) });
}
