import { json, now } from '../../../_lib.js';

// GET /api/admin/tickets?status=open|answered|closed|all
export async function onRequestGet({ request, env }) {
  // Retention: closed requests are deleted 12 months after their last update.
  const cutoff = now() - 365 * 86400;
  await env.DB.batch([
    env.DB.prepare("DELETE FROM messages WHERE ticket_id IN (SELECT id FROM tickets WHERE status = 'closed' AND updated_at < ?)").bind(cutoff),
    env.DB.prepare("DELETE FROM tickets WHERE status = 'closed' AND updated_at < ?").bind(cutoff),
  ]);

  const status = new URL(request.url).searchParams.get('status') || 'open';
  const filtered = ['open', 'answered', 'closed'].includes(status);
  const sql = `SELECT t.id, t.topic, t.platform, t.app_version, t.status, t.created_at, t.updated_at, t.unread_admin,
      (SELECT body FROM messages m WHERE m.ticket_id = t.id ORDER BY m.created_at DESC, m.id DESC LIMIT 1) AS last
    FROM tickets t ${filtered ? 'WHERE t.status = ?' : ''} ORDER BY t.unread_admin DESC, t.updated_at DESC LIMIT 200`;
  const { results } = await (filtered ? env.DB.prepare(sql).bind(status) : env.DB.prepare(sql)).all();
  const counts = await env.DB.prepare(
    "SELECT COALESCE(SUM(status = 'open'), 0) AS open, COALESCE(SUM(status = 'answered'), 0) AS answered, COALESCE(SUM(status = 'closed'), 0) AS closed, COALESCE(SUM(unread_admin), 0) AS unread FROM tickets",
  ).first();
  return json(request, { tickets: results, counts });
}
