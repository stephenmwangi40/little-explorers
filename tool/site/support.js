// Support form and "check my request" for parents.
(function () {
  'use strict';
  var API = /little-explorers-app\.pages\.dev$/.test(location.hostname) ? '' : 'https://little-explorers-app.pages.dev';
  var $ = function (id) { return document.getElementById(id); };

  function store(key, value) {
    try { if (value === undefined) return localStorage.getItem(key); localStorage.setItem(key, value); } catch (e) { return null; }
  }

  function when(ts) {
    try { return new Date(ts * 1000).toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' }); } catch (e) { return ''; }
  }

  function setStatus(el, text, ok) {
    el.textContent = text;
    el.className = 'notice ' + (ok ? 'ok' : 'bad');
    el.hidden = !text;
  }

  async function call(path, opts) {
    var res = await fetch(API + path, opts);
    var data = {};
    try { data = await res.json(); } catch (e) {}
    if (!res.ok) throw new Error(data.error || 'Something went wrong. Please try again.');
    return data;
  }

  // ---------------------------------------------------------- new request
  var form = $('contact');
  if (form) {
    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      var btn = form.querySelector('button[type=submit]');
      var msg = $('contact-status');
      btn.disabled = true;
      setStatus(msg, 'Sending…', true);
      try {
        var data = await call('/api/tickets', {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({
            topic: form.topic.value,
            platform: form.platform.value,
            appVersion: form.appVersion.value,
            message: form.message.value,
            website: form.website.value,
          }),
        });
        store('le_ticket', data.id);
        store('le_code', data.code);
        form.reset();
        setStatus(msg, '', true);
        $('ticket-made').hidden = false;
        $('made-id').textContent = data.id;
        $('made-code').textContent = data.code;
        $('lookup-id').value = data.id;
        $('lookup-code').value = data.code;
      } catch (err) {
        setStatus(msg, err.message, false);
      } finally {
        btn.disabled = false;
      }
    });
  }

  // ---------------------------------------------------------- check request
  var lookup = $('lookup');
  function render(data) {
    var box = $('thread');
    box.hidden = false;
    $('thread-title').textContent = data.id + ' · ' + data.topic;
    var label = { open: 'Waiting for our reply', answered: 'We replied', closed: 'Closed' }[data.status] || data.status;
    $('thread-status').textContent = label;
    $('thread-status').className = 'pill-status ' + data.status;
    var list = $('thread-messages');
    list.textContent = '';
    data.messages.forEach(function (m) {
      var li = document.createElement('li');
      li.className = 'bubble-msg ' + m.author;
      var who = document.createElement('b');
      who.textContent = m.author === 'support' ? 'Little Explorers support' : 'You';
      var time = document.createElement('small');
      time.textContent = ' · ' + when(m.created_at);
      var p = document.createElement('p');
      p.textContent = m.body;
      li.append(who, time, p);
      list.append(li);
    });
    $('followup').hidden = data.status === 'closed';
    watch(data.status !== 'closed');
  }

  // While a request is open on screen, new replies appear by themselves.
  var poll = null;
  var lastCount = 0;
  function watch(on) {
    if (poll) clearInterval(poll);
    poll = null;
    if (!on) return;
    lastCount = document.querySelectorAll('#thread-messages li').length;
    poll = setInterval(async function () {
      if (document.hidden || $('thread').hidden) return;
      try {
        var data = await call('/api/tickets/' + encodeURIComponent($('lookup-id').value.trim().toUpperCase()), {
          headers: { 'x-ticket-code': $('lookup-code').value.trim().toUpperCase() },
        });
        if (data.messages.length !== lastCount || data.status === 'closed') render(data);
      } catch (e) {}
    }, 20000);
  }

  async function load() {
    var id = $('lookup-id').value.trim().toUpperCase();
    var code = $('lookup-code').value.trim().toUpperCase();
    var msg = $('lookup-status');
    if (!id || !code) { setStatus(msg, 'Enter your request number and code.', false); return; }
    setStatus(msg, 'Checking…', true);
    try {
      var data = await call('/api/tickets/' + encodeURIComponent(id), { headers: { 'x-ticket-code': code } });
      setStatus(msg, '', true);
      store('le_ticket', id);
      store('le_code', code);
      render(data);
    } catch (err) {
      $('thread').hidden = true;
      setStatus(msg, err.message, false);
    }
  }

  if (lookup) {
    lookup.addEventListener('submit', function (e) { e.preventDefault(); load(); });
    var params = new URLSearchParams(location.search);
    var id = params.get('t') || store('le_ticket');
    var code = params.get('c') || store('le_code');
    if (id) $('lookup-id').value = id;
    if (code) $('lookup-code').value = code;
  }

  var follow = $('followup');
  if (follow) {
    follow.addEventListener('submit', async function (e) {
      e.preventDefault();
      var msg = $('followup-status');
      try {
        var data = await call('/api/tickets/' + encodeURIComponent($('lookup-id').value.trim().toUpperCase()), {
          method: 'POST',
          headers: { 'content-type': 'application/json', 'x-ticket-code': $('lookup-code').value.trim().toUpperCase() },
          body: JSON.stringify({ message: follow.message.value }),
        });
        follow.reset();
        setStatus(msg, 'Sent. We will reply here.', true);
        await load();
      } catch (err) {
        setStatus(msg, err.message, false);
      }
    });
  }
})();
