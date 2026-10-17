// Little Explorers Support Desk (stand-alone admin app).
(function () {
  'use strict';
  var $ = function (id) { return document.getElementById(id); };
  var KEY = 'le_admin';
  var POLL_MS = 20000;
  var state = { filter: 'open', current: null, tickets: [], lastUpdate: 0, timer: null };
  var wide = window.matchMedia('(min-width: 900px)');

  var okHost = /little-explorers-app\.pages\.dev$/.test(location.hostname) || /^(localhost|127\.0\.0\.1)$/.test(location.hostname);
  if (!okHost) {
    $('elsewhere').hidden = false;
    $('login').querySelector('button[type=submit]').disabled = true;
    return;
  }

  // ---------------------------------------------------------- helpers
  function pass(v) {
    try {
      if (v === undefined) return sessionStorage.getItem(KEY) || '';
      if (v === null) sessionStorage.removeItem(KEY); else sessionStorage.setItem(KEY, v);
    } catch (e) { return ''; }
    return '';
  }
  function when(ts) {
    try { return new Date(ts * 1000).toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' }); } catch (e) { return ''; }
  }
  function ago(ts) {
    var s = Math.max(0, Math.round(Date.now() / 1000 - ts));
    if (s < 60) return 'just now';
    if (s < 3600) return Math.round(s / 60) + ' min ago';
    if (s < 86400) return Math.round(s / 3600) + ' h ago';
    return when(ts);
  }
  function notice(el, text, ok) { el.textContent = text; el.className = 'notice ' + (ok ? 'ok' : 'bad'); el.hidden = !text; }
  function el(tag, cls, text) { var e = document.createElement(tag); if (cls) e.className = cls; if (text != null) e.textContent = text; return e; }

  async function api(path, opts) {
    opts = opts || {};
    opts.headers = Object.assign({ authorization: 'Bearer ' + pass(), 'content-type': 'application/json' }, opts.headers || {});
    var res = await fetch(path, opts);
    var data = {};
    try { data = await res.json(); } catch (e) {}
    if (res.status === 401) { signOut(); throw new Error('Wrong password.'); }
    if (!res.ok) throw new Error(data.error || 'Something went wrong. Please try again.');
    return data;
  }

  // ---------------------------------------------------------- views
  function setView(view) {
    $('layout').setAttribute('data-view', view);
    if (!wide.matches) window.scrollTo({ top: 0 });
  }
  function goHome() {
    state.current = null;
    $('detail').hidden = true;
    $('detail-empty').hidden = false;
    setView('home');
    render();
    refresh();
  }
  // Re-layout instantly when the screen size or orientation changes.
  wide.addEventListener('change', function () {
    setView(state.current && !wide.matches ? 'detail' : 'home');
  });

  // ---------------------------------------------------------- sign in / out
  function showApp() {
    $('login-view').hidden = true;
    $('app').hidden = false;
    var h = new Date().getHours();
    $('greeting').textContent = h < 12 ? 'Good morning!' : h < 18 ? 'Good afternoon!' : 'Good evening!';
    startPolling();
  }
  function signOut() {
    pass(null);
    stopPolling();
    state.current = null;
    $('app').hidden = true;
    $('login-view').hidden = false;
    document.title = 'Support Desk · Little Explorers';
  }
  $('login').addEventListener('submit', async function (e) {
    e.preventDefault();
    var btn = $('login').querySelector('button[type=submit]');
    btn.disabled = true;
    pass($('password').value);
    try {
      await refresh(true);
      $('password').value = '';
      notice($('login-status'), '', true);
      showApp();
    } catch (err) {
      pass(null);
      notice($('login-status'), err.message, false);
    } finally {
      btn.disabled = false;
    }
  });
  $('signout').addEventListener('click', signOut);
  $('home').addEventListener('click', goHome);
  $('home-btn').addEventListener('click', goHome);
  $('back').addEventListener('click', goHome);
  $('refresh').addEventListener('click', function () { refresh(); if (state.current) openTicket(state.current, true); });

  // ---------------------------------------------------------- list
  document.querySelectorAll('[data-filter]').forEach(function (b) {
    b.addEventListener('click', function () { state.filter = b.getAttribute('data-filter'); refresh(); });
  });
  $('show-all').addEventListener('click', function () { state.filter = 'all'; refresh(); });
  $('search').addEventListener('input', render);

  async function refresh(throwErrors) {
    try {
      var status = state.filter === 'unread' ? 'all' : state.filter;
      var data = await api('/api/admin/tickets?status=' + status);
      var c = data.counts || {};
      ['unread', 'open', 'answered', 'closed'].forEach(function (k) { $('count-' + k).textContent = c[k] || 0; });
      state.tickets = state.filter === 'unread' ? data.tickets.filter(function (t) { return t.unread_admin; }) : data.tickets;
      state.lastUpdate = Date.now();
      var n = c.unread || 0;
      document.title = (n ? '(' + n + ') ' : '') + 'Support Desk · Little Explorers';
      $('summary').textContent = n === 0 ? 'No new messages. Everything is answered.' : n === 1 ? '1 request has a new message.' : n + ' requests have new messages.';
      render();
      tick();
    } catch (err) {
      if (throwErrors) throw err;
      $('updated').textContent = 'Offline – retrying';
    }
  }

  function render() {
    document.querySelectorAll('[data-filter]').forEach(function (b) {
      b.setAttribute('aria-selected', String(b.getAttribute('data-filter') === state.filter));
    });
    $('show-all').setAttribute('aria-pressed', String(state.filter === 'all'));
    var q = $('search').value.trim().toLowerCase();
    var list = $('tickets');
    list.textContent = '';
    var shown = state.tickets.filter(function (t) {
      return !q || (t.id + ' ' + t.topic + ' ' + (t.platform || '') + ' ' + (t.last || '')).toLowerCase().indexOf(q) >= 0;
    });
    if (!shown.length) {
      list.append(el('li', 'none', q ? 'No requests match your search.' : 'Nothing here right now.'));
      return;
    }
    shown.forEach(function (t) {
      var li = el('li');
      var b = el('button', 'ticket' + (t.unread_admin ? ' unread' : '') + (state.current === t.id ? ' active' : ''));
      b.type = 'button';
      var top = el('span', 'top');
      top.append(el('span', 'id', t.id), el('span', 'status ' + t.status, t.status));
      b.append(top, el('span', 'topic', t.topic + (t.platform ? ' · ' + t.platform : '')), el('span', 'last', t.last || ''), el('small', '', ago(t.updated_at)));
      b.addEventListener('click', function () { openTicket(t.id); });
      li.append(b);
      list.append(li);
    });
  }

  // ---------------------------------------------------------- conversation
  function show(t) {
    state.current = t.id;
    $('detail-empty').hidden = true;
    $('detail').hidden = false;
    $('d-title').textContent = t.id + ' · ' + t.topic;
    $('d-meta').textContent = [t.platform, t.app_version ? 'app ' + t.app_version : '', 'opened ' + when(t.created_at)].filter(Boolean).join(' · ');
    $('d-status').textContent = t.status;
    $('d-status').className = 'status ' + t.status;
    var box = $('d-messages');
    var atBottom = box.scrollHeight - box.scrollTop - box.clientHeight < 40;
    box.textContent = '';
    t.messages.forEach(function (m) {
      var li = el('li', 'msg ' + m.author);
      li.append(el('b', '', m.author === 'support' ? 'You (support)' : 'Parent'), el('small', '', ' · ' + when(m.created_at)), el('p', '', m.body));
      box.append(li);
    });
    if (atBottom || box.dataset.ticket !== t.id) box.scrollTop = box.scrollHeight;
    box.dataset.ticket = t.id;
    $('close').hidden = t.status === 'closed';
    $('reopen').hidden = t.status !== 'closed';
  }

  async function openTicket(id, quiet) {
    try {
      show(await api('/api/admin/tickets/' + encodeURIComponent(id)));
      if (!quiet) {
        notice($('d-status-msg'), '', true);
        setView('detail');
        refresh();
      }
    } catch (err) {
      if (!quiet) notice($('d-status-msg'), err.message, false);
    }
  }

  async function act(action, message) {
    var msg = $('d-status-msg');
    try {
      var data = await api('/api/admin/tickets/' + encodeURIComponent(state.current), {
        method: 'POST',
        body: JSON.stringify({ action: action, message: message }),
      });
      if (data.deleted) {
        notice(msg, '', true);
        goHome();
        return;
      }
      show(data);
      notice(msg, action === 'reply' ? 'Reply sent. The parent sees it on the support page.' : action === 'close' ? 'Marked closed.' : 'Reopened.', true);
      refresh();
    } catch (err) { notice(msg, err.message, false); }
  }

  $('reply').addEventListener('submit', async function (e) {
    e.preventDefault();
    var text = $('reply-text').value.trim();
    if (!text) return;
    var btn = $('reply').querySelector('button[type=submit]');
    btn.disabled = true;
    await act('reply', text);
    btn.disabled = false;
    if ($('d-status-msg').className.indexOf('ok') >= 0) $('reply-text').value = '';
  });
  document.querySelectorAll('[data-template]').forEach(function (b) {
    b.addEventListener('click', function () { $('reply-text').value = b.getAttribute('data-template'); $('reply-text').focus(); });
  });
  $('close').addEventListener('click', function () { act('close'); });
  $('reopen').addEventListener('click', function () { act('reopen'); });
  $('delete').addEventListener('click', function () {
    if (confirm('Delete this request and all its messages for good?')) act('delete');
  });

  // ---------------------------------------------------------- live updates
  function tick() {
    if (!state.lastUpdate) return;
    var s = Math.round((Date.now() - state.lastUpdate) / 1000);
    $('updated').textContent = s < 10 ? 'Updated just now' : 'Updated ' + s + ' s ago';
  }
  function startPolling() {
    stopPolling();
    state.timer = setInterval(function () {
      tick();
      if (document.hidden) return;
      if (Date.now() - state.lastUpdate >= POLL_MS) {
        refresh();
        if (state.current) openTicket(state.current, true);
      }
    }, 5000);
  }
  function stopPolling() { if (state.timer) clearInterval(state.timer); state.timer = null; }
  document.addEventListener('visibilitychange', function () {
    if (!document.hidden && !$('app').hidden) { refresh(); if (state.current) openTicket(state.current, true); }
  });

  // Stay signed in for this browser tab.
  if (pass()) refresh(true).then(showApp).catch(function () { pass(null); });
})();
