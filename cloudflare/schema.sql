-- Support database (Cloudflare D1: little-explorers-support).
CREATE TABLE IF NOT EXISTS tickets (
  id TEXT PRIMARY KEY,
  code_hash TEXT NOT NULL,
  topic TEXT NOT NULL,
  platform TEXT,
  app_version TEXT,
  status TEXT NOT NULL DEFAULT 'open',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  unread_admin INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticket_id TEXT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  author TEXT NOT NULL CHECK (author IN ('parent', 'support')),
  body TEXT NOT NULL,
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_messages_ticket ON messages(ticket_id, created_at);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status, updated_at);
-- Short-lived spam protection: hashed IP address and time, kept 1 day.
CREATE TABLE IF NOT EXISTS rate (key TEXT NOT NULL, at INTEGER NOT NULL);
CREATE INDEX IF NOT EXISTS idx_rate ON rate(key, at);
