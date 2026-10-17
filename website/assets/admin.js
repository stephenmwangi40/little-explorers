// Support admin dashboard: sign in, list requests, read and reply.
(function () {
  'use strict';
  var $ = function (id) { return document.getElementById(id); };
  var KEY = 'le_admin';
  var filter = 'open';
  var current = null;

  if (!/little-explorers-app\.pages\.dev$/.test(location.hostname) && location.hostname !== 'localhost') {
    $('login').hidden = true;
    $('elsewhere').hidden = false;
    return;
  }

  function pass(v) {
    try {
      if (v === undefined) return sessionStorage.getItem(KEY) || '';
      if (v === null) sessionStorage.removeItem(KEY); else sessionStorage.setItem(KEY, v);
    } catch (e) { return ''; }
  }
  function when(ts) {
    try { return new Date(ts * 1000).toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' }); } catch (e) { return ''; }
  }
  function notice(el, text, ok) { el.textContent = text; el.className = 'notice ' + (ok ? 'ok' : 'bad'); el.hidden = !text; }

  async function api(path, opts) {
    opts = opts || {};
    opts.headers = Object.assign({ authorization: 'Bearer ' + pass(), 'content-type': 'application/json' }, opts.headers || {});
    var res = await fetch(path, opts);
    var data = {};
    try { data = await res.json(); } catch (e) {}
    if (res.status === 401) { signOut(); throw new Error('Wrong password.'); }
    if (!res.ok) throw new Error(data.error || 'Something went wrong.');
    return data;
  }

  function signOut() {
    pass(null);
    $('dash').hidden = true;
    $('signout').hidden = true;
    $('login').hidden = false;
  }
  function signedIn() {
    $('login').hidden = true;
    $('dash').hidden = false;
    $('signout').hidden = false;
  }

  // ---------------------------------------------------------- sign in
  $('login').addEventListener('submit', async function (e) {
    e.preventDefault();
    pass($('password').value);
    try {
      await refresh();
      $('password').value = '';
      signedIn();
      notice($('login-status'), '', true);
    } catch (err) {
      pass(null);
      notice($('login-status'), err.message, false);
    }
  });
  $('signout').addEventListener('click', signOut);

  // ---------------------------------------------------------- list
  document.querySelectorAll('[data-filter]').forEach(function (b) {
    b.addEventListener('click', function () {
      filter = b.getAttribute('data-filter');
      document.querySelectorAll('[data-filter]').forEach(function (x) { x.setAttribute('aria-pressed', String(x === b)); });
      refresh();
    });
  });
  $('reload').addEventListener('click', function () { refresh(); });

  async function refresh() {
    var data = await api('/api/admin/tickets?status=' + filter);
    var c = data.counts || {};
    $('count-open').textContent = c.open || 0;
    $('count-answered').textContent = c.answered || 0;
    $('count-closed').textContent = c.closed || 0;
    $('count-unread').textContent = c.unread || 0;
    var list = $('tickets');
    list.textContent = '';
    if (!data.tickets.length) {
      var empty = document.createElement('li');
      empty.className = 'empty';
      empty.textContent = 'No requests here.';
      list.append(empty);
    }
    data.tickets.forEach(function (t) {
      var li = document.createElement('li');
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'ticket-row' + (t.unread_admin ? ' unread' : '') + (current === t.id ? ' active' : '');
      var top = document.createElement('span');
      top.className = 'row-top';
      var id = document.createElement('b');
      id.textContent = t.id;
      var st = document.createElement('span');
      st.className = 'pill-status ' + t.status;
      st.textContent = t.status;
      top.append(id, st);
      var topic = document.createElement('span');
      topic.className = 'row-topic';
      topic.textContent = t.topic + (t.platform ? ' · ' + t.platform : '');
      var last = document.createElement('span');
      last.className = 'row-last';
      last.textContent = (t.last || '').slice(0, 120);
      var time = document.createElement('small');
      time.textContent = when(t.updated_at);
      btn.append(top, topic, last, time);
      btn.addEventListener('click', function () { open(t.id); });
      li.append(btn);
      list.append(li);
    });
    return data;
  }

  // ---------------------------------------------------------- detail
  function show(t) {
    current = t.id;
    $('detail').hidden = false;
    $('detail-empty').hidden = true;
    $('d-title').textContent = t.id + ' · ' + t.topic;
    $('d-meta').textContent = [t.platform, t.app_version ? 'v' + t.app_version : '', 'opened ' + when(t.created_at)].filter(Boolean).join(' · ');
    $('d-status').textContent = t.status;
    $('d-status').className = 'pill-status ' + t.status;
    var list = $('d-messages');
    list.textContent = '';
    t.messages.forEach(function (m) {
      var li = document.createElement('li');
      li.className = 'bubble-msg ' + m.author;
      var who = document.createElement('b');
      who.textContent = m.author === 'support' ? 'Support (you)' : 'Parent';
      var time = document.createElement('small');
      time.textContent = ' · ' + when(m.created_at);
      var p = document.createElement('p');
      p.textContent = m.body;
      li.append(who, time, p);
      list.append(li);
    });
    $('close').hidden = t.status === 'closed';
    $('reopen').hidden = t.status !== 'closed';
    if (window.matchMedia('(max-width: 900px)').matches) $('detail').scrollIntoView({ behavior: 'smooth' });
  }

  async function open(id) {
    try {
      show(await api('/api/admin/tickets/' + encodeURIComponent(id)));
      refresh();
    } catch (err) { notice($('d-status-msg'), err.message, false); }
  }

  async function act(action, message) {
    var msg = $('d-status-msg');
    try {
      var data = await api('/api/admin/tickets/' + encodeURIComponent(current), {
        method: 'POST',
        body: JSON.stringify({ action: action, message: message }),
      });
      if (data.deleted) {
        current = null;
        $('detail').hidden = true;
        $('detail-empty').hidden = false;
        notice(msg, '', true);
      } else {
        show(data);
        notice(msg, action === 'reply' ? 'Reply sent. The parent sees it when they check their request.' : 'Saved.', true);
      }
      refresh();
    } catch (err) { notice(msg, err.message, false); }
  }

  $('reply').addEventListener('submit', function (e) {
    e.preventDefault();
    var text = $('reply-text').value.trim();
    if (!text) return;
    act('reply', text).then(function () { $('reply-text').value = ''; });
  });
  document.querySelectorAll('[data-template]').forEach(function (b) {
    b.addEventListener('click', function () { $('reply-text').value = b.getAttribute('data-template'); $('reply-text').focus(); });
  });
  $('close').addEventListener('click', function () { act('close'); });
  $('reopen').addEventListener('click', function () { act('reopen'); });
  $('delete').addEventListener('click', function () {
    if (confirm('Delete this request and its messages permanently?')) act('delete');
  });

  if (pass()) {
    refresh().then(signedIn).catch(function () { pass(null); });
  }
})();
