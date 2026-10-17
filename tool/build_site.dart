// Builds the public information website (no web app) into website/.
// Run: dart run tool/build_site.dart
//
// Design: minimal "liquid glass" panels over SOLID colours. No gradients.
// Responsive for phones, tablets, laptops and desktops.
import 'dart:io';

const appName = 'Little Explorers';
const repo = 'https://github.com/stephenmwangi40/little-explorers';
const supportLink = '$repo/issues/new';
const updated = '17 October 2026';

const owl = '''<svg class="owl" viewBox="0 0 120 124" role="img" aria-label="Tiko the owl">
<ellipse cx="60" cy="119" rx="30" ry="4.5" fill="rgba(31,42,68,.15)"/>
<path d="M28 34L33 9L50 26Z" fill="#4E3FC9"/><path d="M92 34L87 9L70 26Z" fill="#4E3FC9"/>
<ellipse cx="20" cy="74" rx="10" ry="22" fill="#4E3FC9"/><ellipse cx="100" cy="74" rx="10" ry="22" fill="#4E3FC9"/>
<ellipse cx="60" cy="66" rx="42" ry="46" fill="#6C5CE7"/><ellipse cx="60" cy="84" rx="25" ry="24" fill="#FFE8B6"/>
<path d="M50 82q4 4 8 0M62 82q4 4 8 0M56 92q4 4 8 0" fill="none" stroke="#F2C879" stroke-width="2.2" stroke-linecap="round"/>
<g class="eyes"><circle cx="44" cy="52" r="15" fill="#fff"/><circle cx="76" cy="52" r="15" fill="#fff"/><circle cx="46" cy="54" r="7.5" fill="#1F2A44"/><circle cx="74" cy="54" r="7.5" fill="#1F2A44"/><circle cx="48.5" cy="51" r="2.6" fill="#fff"/><circle cx="76.5" cy="51" r="2.6" fill="#fff"/></g>
<path d="M53 66L67 66L60 76Z" fill="#FF9F1C"/><circle cx="30" cy="69" r="5" fill="#FF8FAB"/><circle cx="90" cy="69" r="5" fill="#FF8FAB"/>
<ellipse cx="48" cy="111" rx="8" ry="4" fill="#FF9F1C"/><ellipse cx="72" cy="111" rx="8" ry="4" fill="#FF9F1C"/></svg>''';

const css = r'''
:root{
  --bg:#7ED3F7;--blob1:#A4E1FA;--blob2:#8BD96B;--blob3:#FFD166;
  --ink:#1F2A44;--muted:#4A5672;--glass:rgba(255,255,255,.34);--glass-strong:rgba(255,255,255,.72);
  --edge:rgba(255,255,255,.7);--shadow:0 10px 30px rgba(31,42,68,.12);--accent:#6C5CE7;--green:#3DBE7A;--green-d:#2A9D60;
  --r:26px;
}
@media (prefers-color-scheme:dark){
  :root{--bg:#2E3A5C;--blob1:#3B4A72;--blob2:#2A6B57;--blob3:#5A4BB8;--ink:#F2F5FB;--muted:#C3CBE0;
  --glass:rgba(255,255,255,.10);--glass-strong:rgba(30,38,62,.72);--edge:rgba(255,255,255,.22);--shadow:0 10px 30px rgba(0,0,0,.3);--accent:#B8AEFF}
}
*{box-sizing:border-box}
html{-webkit-text-size-adjust:100%}
body{margin:0;background:var(--bg);color:var(--ink);font:500 17px/1.6 "Nunito",system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;min-height:100vh;overflow-x:hidden}
.blobs{position:fixed;inset:0;z-index:-1;pointer-events:none;overflow:hidden}
.blobs i{position:absolute;border-radius:50%;display:block}
.blobs i:nth-child(1){width:46vmax;height:46vmax;background:var(--blob1);left:-14vmax;top:-12vmax}
.blobs i:nth-child(2){width:38vmax;height:38vmax;background:var(--blob2);right:-14vmax;bottom:-16vmax}
.blobs i:nth-child(3){width:14vmax;height:14vmax;background:var(--blob3);right:8vmax;top:14vh}
h1,h2,h3{font-family:"Baloo 2","Nunito",system-ui,sans-serif;line-height:1.1;margin:0 0 .4em;letter-spacing:-.01em}
h1{font-size:clamp(2.2rem,6vw,4rem)}h2{font-size:clamp(1.5rem,3.2vw,2.2rem)}h3{font-size:1.25rem}
p{margin:0 0 1em}a{color:var(--accent);font-weight:800;text-underline-offset:3px}
.wrap{width:min(1120px,100% - 32px);margin:0 auto}
.glass{background:var(--glass);-webkit-backdrop-filter:blur(18px) saturate(160%);backdrop-filter:blur(18px) saturate(160%);
  border:1.5px solid var(--edge);border-radius:var(--r);box-shadow:var(--shadow)}
.glass.strong{background:var(--glass-strong)}
@supports not ((backdrop-filter:blur(1px)) or (-webkit-backdrop-filter:blur(1px))){.glass{background:var(--glass-strong)}}
header.top{position:sticky;top:12px;z-index:10;margin:12px auto 0}
header.top .bar{display:flex;align-items:center;gap:12px;padding:8px 10px 8px 14px}
.brand{display:flex;align-items:center;gap:10px;text-decoration:none;color:var(--ink);font:800 1.15rem "Baloo 2",system-ui;flex:none}
.brand .owl{width:38px;height:40px}
nav{margin-left:auto;display:flex;gap:4px;flex-wrap:wrap;justify-content:flex-end}
nav a{color:var(--ink);text-decoration:none;font-weight:800;font-size:.95rem;padding:8px 12px;border-radius:14px}
nav a[aria-current=page],nav a:hover{background:var(--glass-strong)}
.menu{display:none;margin-left:auto;align-items:center;justify-content:center;width:46px;height:46px;border-radius:50%;border:1.5px solid var(--edge);background:var(--glass-strong);color:var(--ink);font-size:1.2rem;cursor:pointer}
@media (max-width:720px){nav{display:none}.menu{display:inline-flex}}
@media (min-width:721px){.sheet{display:none!important}}
.table-wrap{overflow-x:auto;-webkit-overflow-scrolling:touch;margin:.6em 0 1.2em}
.table-wrap table{margin:0}
h1,h2,h3,p,li,summary{overflow-wrap:break-word}
img,svg{max-width:100%}
.sheet{display:none;padding:8px;margin-top:8px}
.sheet a{display:block;padding:12px 14px;border-radius:14px;color:var(--ink);text-decoration:none;font-weight:800}
.sheet.open{display:block}
main{padding:28px 0 40px}
.hero{display:grid;grid-template-columns:1.15fr .85fr;gap:28px;align-items:center;padding:clamp(22px,4vw,48px)}
.hero .owl{width:min(260px,60vw);height:auto;display:block;margin:auto}
.hero p.lead{font-size:clamp(1.05rem,2vw,1.3rem);color:var(--muted);max-width:34ch}
@media (max-width:820px){.hero{grid-template-columns:1fr;text-align:center}.hero p.lead{margin-inline:auto}.badges{justify-content:center}}
.badges{display:flex;gap:10px;flex-wrap:wrap;margin-top:18px}
.badge{display:inline-flex;align-items:center;gap:10px;padding:12px 18px;border-radius:18px;background:var(--ink);color:var(--bg);font-weight:800;text-decoration:none}
.btn{display:inline-block;padding:12px 22px;border-radius:20px;background:var(--green);color:#fff;font-weight:800;text-decoration:none;box-shadow:0 5px 0 var(--green-d)}
.btn:active{transform:translateY(3px);box-shadow:0 2px 0 var(--green-d)}
.chips{display:flex;flex-wrap:wrap;gap:8px;margin-top:6px}
.chip{padding:6px 12px;border-radius:12px;background:var(--glass-strong);font-weight:800;font-size:.9rem}
section{margin-top:26px}
.section{padding:clamp(20px,3.5vw,36px)}
.grid{display:grid;gap:16px;grid-template-columns:repeat(auto-fit,minmax(min(100%,250px),1fr))}
.card{padding:20px}
.card .dot{width:52px;height:52px;border-radius:16px;display:grid;place-items:center;color:#fff;font:800 1.2rem "Baloo 2",system-ui;margin-bottom:12px;box-shadow:0 4px 0 rgba(31,42,68,.18)}
.card p{color:var(--muted);margin:0}
.shots{display:grid;grid-auto-flow:column;grid-auto-columns:min(230px,62vw);gap:16px;overflow-x:auto;padding:4px 4px 16px;scroll-snap-type:x mandatory}
.shots figure{margin:0;scroll-snap-align:start}
.shots img{width:100%;height:auto;border-radius:22px;border:1.5px solid var(--edge);display:block;box-shadow:var(--shadow)}
.shots figcaption{text-align:center;font-weight:800;font-size:.9rem;margin-top:8px;color:var(--muted)}
.prose{padding:clamp(22px,4vw,48px);max-width:860px;margin:auto}
.prose h2{margin-top:1.4em}.prose h2:first-of-type{margin-top:.2em}
.prose ul{padding-left:1.2em}.prose li{margin:.35em 0}
.prose .meta{color:var(--muted);font-weight:700}
table{width:100%;border-collapse:collapse;margin:.6em 0 1.2em;font-size:.95rem}
th,td{text-align:left;padding:10px 8px;border-bottom:1px solid var(--edge);vertical-align:top}
details{padding:14px 18px;margin:10px 0}
summary{cursor:pointer;font-weight:800;font-size:1.05rem}
details p{margin:.6em 0 0;color:var(--muted)}
footer{padding:22px 0 40px}
footer .bar{padding:18px 20px;display:flex;flex-wrap:wrap;gap:10px 18px;align-items:center;justify-content:space-between}
footer a{color:var(--ink)}
footer small{color:var(--muted)}
/* Forms */
.form{display:grid;gap:14px}
.form .row2{display:grid;gap:14px;grid-template-columns:repeat(auto-fit,minmax(min(100%,220px),1fr))}
label{display:grid;gap:6px;font-weight:800}
input,select,textarea{font:inherit;color:var(--ink);background:var(--glass-strong);border:1.5px solid var(--edge);border-radius:16px;padding:12px 14px;width:100%}
textarea{min-height:130px;resize:vertical}
input:focus-visible,select:focus-visible,textarea:focus-visible{outline:3px solid var(--accent);outline-offset:2px}
button.btn{border:0;cursor:pointer;font:inherit;font-weight:800}
button.btn[disabled]{opacity:.6;cursor:wait}
.btn.ghost{background:var(--glass-strong);color:var(--ink);box-shadow:0 5px 0 rgba(31,42,68,.18)}
.btn.danger{background:#D64545;box-shadow:0 5px 0 #A83232}
.hp{position:absolute;left:-9999px;width:1px;height:1px;overflow:hidden}
.notice{padding:10px 14px;border-radius:14px;font-weight:800;margin:0}
.notice.ok{background:rgba(61,190,122,.18)}.notice.bad{background:rgba(214,69,69,.18)}
.made{padding:18px;border:2px dashed var(--edge);border-radius:20px}
.code{font:800 1.4rem/1.2 ui-monospace,Menlo,Consolas,monospace;letter-spacing:.08em}
/* Conversations */
.pill-status{display:inline-block;padding:3px 10px;border-radius:10px;font-weight:800;font-size:.8rem;text-transform:capitalize;background:var(--glass-strong)}
.pill-status.open{background:#FFD166;color:#1F2A44}.pill-status.answered{background:#3DBE7A;color:#fff}.pill-status.closed{background:#C5CFDD;color:#1F2A44}
.messages{list-style:none;padding:0;margin:12px 0;display:grid;gap:10px}
.bubble-msg{padding:12px 16px;border-radius:18px;max-width:85%;background:var(--glass-strong);border:1.5px solid var(--edge)}
.bubble-msg.support{justify-self:end;background:#6C5CE7;color:#fff;border-color:#6C5CE7}
.bubble-msg p{margin:.3em 0 0;white-space:pre-wrap;overflow-wrap:anywhere}
.bubble-msg small{opacity:.75}
/* Admin */
.admin-grid{display:grid;grid-template-columns:minmax(280px,380px) 1fr;gap:16px;align-items:start}
@media (max-width:900px){.admin-grid{grid-template-columns:1fr}}
.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:14px}
.stat{padding:12px;text-align:center}.stat b{display:block;font:800 1.6rem "Baloo 2",system-ui}
@media (max-width:520px){.stats{grid-template-columns:repeat(2,1fr)}}
.tabs{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:10px}
.tabs button{font:inherit;font-weight:800;border:1.5px solid var(--edge);background:var(--glass);color:var(--ink);padding:8px 14px;border-radius:14px;cursor:pointer}
.tabs button[aria-pressed=true]{background:var(--ink);color:var(--bg)}
.tickets{list-style:none;padding:0;margin:0;display:grid;gap:8px;max-height:70vh;overflow:auto}
.ticket-row{width:100%;text-align:left;font:inherit;color:var(--ink);display:grid;gap:4px;padding:12px 14px;border-radius:16px;border:1.5px solid var(--edge);background:var(--glass);cursor:pointer}
.ticket-row.unread{border-color:#FFB703;box-shadow:inset 4px 0 0 #FFB703}
.ticket-row.active{background:var(--glass-strong)}
.row-top{display:flex;justify-content:space-between;align-items:center;gap:8px}
.row-topic{font-weight:800}.row-last{color:var(--muted);font-size:.92rem;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.tickets .empty{padding:14px;color:var(--muted);font-weight:700}
.templates{display:flex;gap:6px;flex-wrap:wrap}
.templates button{font:inherit;font-size:.85rem;font-weight:800;border:1.5px solid var(--edge);background:var(--glass);color:var(--ink);padding:6px 10px;border-radius:12px;cursor:pointer}
.actions{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
.skip{position:absolute;left:-999px}.skip:focus{left:16px;top:16px;z-index:99;background:#fff;padding:10px;border-radius:10px}
a:focus-visible,button:focus-visible,summary:focus-visible{outline:3px solid var(--accent);outline-offset:3px}
@media (prefers-reduced-motion:no-preference){.owl .eyes{transform-box:fill-box;transform-origin:center;animation:blink 4.2s infinite}}
@keyframes blink{0%,94%,100%{transform:scaleY(1)}97%{transform:scaleY(.1)}}
''';

/// Changes whenever styles or scripts change (see main).
var assetVersion = '1';

const pages = <String, String>{
  '': 'Home',
  'parents': 'For parents',
  'privacy': 'Privacy',
  'terms': 'Terms',
  'support': 'Support',
};

String page(String slug, String title, String description, String body, {String head = '', String scripts = ''}) {
  final depth = slug.isEmpty ? '' : '../';
  final nav = pages.entries
      .map((e) => '<a href="$depth${e.key.isEmpty ? '' : '${e.key}/'}"${e.key == slug ? ' aria-current="page"' : ''}>${e.value}</a>')
      .join();
  body = body.replaceAll('<table>', '<div class="table-wrap"><table>').replaceAll('</table>', '</table></div>');
  final sheet = pages.entries.map((e) => '<a href="$depth${e.key.isEmpty ? '' : '${e.key}/'}">${e.value}</a>').join();
  return '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>$title</title>
<meta name="description" content="$description">
<meta name="theme-color" content="#7ED3F7" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#2E3A5C" media="(prefers-color-scheme: dark)">
<meta property="og:title" content="$title"><meta property="og:description" content="$description">
<meta property="og:image" content="${depth}assets/icon.png">
<link rel="icon" href="${depth}assets/icon.png">
<link rel="apple-touch-icon" href="${depth}assets/icon.png">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@700;800&family=Nunito:wght@500;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${depth}assets/site.css?v=$assetVersion">
$head
</head>
<body>
<a class="skip" href="#main">Skip to content</a>
<div class="blobs" aria-hidden="true"><i></i><i></i><i></i></div>
<header class="top wrap">
  <div class="glass strong bar">
    <a class="brand" href="$depth">$owl<span>$appName</span></a>
    <nav aria-label="Main">$nav</nav>
    <button class="menu" aria-expanded="false" aria-controls="sheet" aria-label="Menu" onclick="var s=document.getElementById('sheet');var o=s.classList.toggle('open');this.setAttribute('aria-expanded',o)">☰</button>
  </div>
  <div id="sheet" class="glass strong sheet">$sheet</div>
</header>
<main id="main" class="wrap">
$body
</main>
<footer class="wrap">
  <div class="glass bar">
    <small>© 2026 $appName · Made for children aged 3–6 and their grown-ups</small>
    <small><a href="${depth}privacy/">Privacy Policy</a> · <a href="${depth}terms/">Terms of Use</a> · <a href="${depth}support/">Support</a></small>
  </div>
</footer>
$scripts
</body>
</html>
''';
}

String card(String color, String glyph, String title, String text) =>
    '<div class="glass card"><div class="dot" style="background:$color">$glyph</div><h3>$title</h3><p>$text</p></div>';

final home = '''
<section class="glass hero" aria-labelledby="h1">
  <div>
    <h1 id="h1">Learn, play and grow with Tiko</h1>
    <p class="lead">A calm, ad-free learning adventure for children aged 3 to 6. Phonics, numbers, shapes, stories, science and movement, in short daily sessions that end with a rest.</p>
    <div class="chips"><span class="chip">Ages 3–6</span><span class="chip">No ads, ever</span><span class="chip">Works offline</span><span class="chip">iPhone · iPad · Android</span></div>
    <div class="badges"><span class="badge">Coming soon to the App Store</span><span class="badge">▶ Coming soon to Google Play</span></div>
  </div>
  <div>$owl</div>
</section>

<section aria-labelledby="worlds">
  <div class="glass section">
    <h2 id="worlds">Eight worlds, 2,400 levels</h2>
    <p>Every world has 300 levels that grow with your child: from first sounds to reading and spelling words, and from counting to 3 to adding to 20 and telling the time.</p>
    <div class="grid">
      ${card('#FF7A59', 'Aa', 'Letters &amp; Sounds', 'Systematic phonics (s a t p i n first), tracing every letter, blending, reading and spelling words, rhymes and tricky words.')}
      ${card('#3DBE7A', '123', 'Math Jungle', 'Counting to 20, quick looks, making 10, adding and taking away, counting in 2s, 5s and 10s, and telling the time.')}
      ${card('#9B6BFF', '◆', 'Shapes &amp; Patterns', 'Shapes turned and resized, 3D shapes, patterns, odd one out, sizes and position words like on, under and next to.')}
      ${card('#2EC4B6', '✿', 'Word Garden', 'Vocabulary for little talkers: naming things, opposites, colours, sorting into groups and what things are for.')}
      ${card('#E86A92', '❤', 'Story Tree', '180 original read-along stories with Momo the turtle, and 80 feelings scenarios that build kindness.')}
      ${card('#4DA3FF', '⚗', 'Wonder Lab', '25 science topics. Children predict, test and explain. Every guess is welcomed.')}
      ${card('#6FBF3A', '♥', 'Healthy Me', 'Healthy habits, staying safe, my body, calm and kind feelings, my day, and days of the week.')}
      ${card('#FFB703', '★', 'Move &amp; Groove', '40 short movement and calm-breathing breaks, with Tiko showing the way.')}
    </div>
  </div>
</section>

<section aria-labelledby="look">
  <div class="glass section">
    <h2 id="look">A look inside</h2>
    <div class="shots">
      <figure><img src="assets/shot-home.png" alt="Home screen with today's adventure and six worlds" width="390" height="844" loading="lazy"><figcaption>Today's adventure</figcaption></figure>
      <figure><img src="assets/shot-add.png" alt="Shape homes game: put each shape in its home" width="390" height="844" loading="lazy"><figcaption>Shape homes</figcaption></figure>
      <figure><img src="assets/shot-order.png" alt="Number line game" width="390" height="844" loading="lazy"><figcaption>Number lines</figcaption></figure>
      <figure><img src="assets/shot-reward.png" alt="Reward screen with three stars and a sticker" width="390" height="844" loading="lazy"><figcaption>Predictable rewards</figcaption></figure>
      <figure><img src="assets/shot-parent.png" alt="Parent dashboard with weekly minutes and skills" width="390" height="844" loading="lazy"><figcaption>Grown-ups dashboard</figcaption></figure>
    </div>
  </div>
</section>

<section aria-labelledby="why">
  <div class="grid">
    ${card('#2E3A5C', '☾', 'Healthy screen time', 'A guided daily adventure (15 to 60 minutes) ends on a calm Rest screen. Daily limits, a bedtime lock and optional reminders for grown-ups are built in.')}
    ${card('#6C5CE7', '🔒', 'Safe by design', 'No ads, no chat, no tracking, no accounts for children. A parental gate protects settings and purchases.')}
    ${card('#3DBE7A', '✓', 'Learns with your child', 'Difficulty adapts, hints step in gently, and skills come back for review after 1, 3, 7 and 21 days.')}
    ${card('#E86A92', '♥', 'Play together', 'Ideas for talking and playing together, on and off the screen, based on what your child just learned.')}
  </div>
</section>

<section aria-labelledby="cta">
  <div class="glass section" style="text-align:center">
    <h2 id="cta">Questions?</h2>
    <p>Read how we keep children safe, or get help with the app.</p>
    <a class="btn" href="parents/">For parents</a>&nbsp; <a class="btn" href="support/" style="background:#4DA3FF;box-shadow:0 5px 0 #2F86E0">Get support</a>
  </div>
</section>
''';

const parents = '''
<article class="glass prose">
<h1>For parents and carers</h1>
<p class="lead">Little Explorers is built around what research says helps young children learn from apps: active thinking, no distractions, meaningful stories, and playing together.</p>

<h2>How a day works</h2>
<ul>
<li><b>Today's Adventure</b> (15, 30, 45 or 60 minutes, you choose): letters → numbers → shapes → words → story → science → healthy me → movement → <b>Rest</b>. The 60-minute adventure adds a second movement break.</li>
<li>The session ends on a calm Rest screen. More time needs a grown-up, through the parental gate.</li>
<li>Default adventure: 45 minutes. Default daily limit: 60 minutes, in line with the guidance of about 1 hour a day for ages 2–5. Optional bedtime lock from 7 pm to 7 am. These work alongside iOS Screen Time and Google Family Link.</li>
<li><b>Optional reminders for grown-ups</b>: a friendly daily notice at a time you choose, and a reminder 2 days before a free trial ends. Off by default, never sent to your child, and never guilt-tripping.</li>
</ul>

<h2>What we never do</h2>
<ul>
<li>No ads, no in-game currencies, no loot boxes or random prizes.</li>
<li>No streaks, countdowns or characters who are sad when your child leaves.</li>
<li>No notifications to children (reminders are only for grown-ups and are off unless you turn them on), and no auto-play of the next activity.</li>
<li>Children never see prices or "ask your parents" prompts. Plans live behind the parental gate.</li>
</ul>

<h2>How it teaches</h2>
<ul>
<li><b>Phonics in a systematic order</b>: s a t p i n, then m d g o c k, and on to vowel teams like ai, ee and oa.</li>
<li><b>Mastery</b>: a skill is secure after 8 of the last 10 answers are right without hints, across at least 2 days.</li>
<li><b>Hints, never failure</b>: hear it again, then see it shown, then do it together. There is no fail screen.</li>
<li><b>Feedback right away</b>: a clear banner and a word from Tiko after every answer.</li>
</ul>

<h2>Curriculum alignment</h2>
<p>Activities are designed to support (not certified by) these frameworks, and the in-app Learning Report shows each link:</p>
<table>
<tr><th>Region</th><th>Frameworks</th></tr>
<tr><td>United States</td><td>Head Start Early Learning Outcomes Framework; Common Core Kindergarten (RF.K, RL.K, K.CC, K.OA, K.G)</td></tr>
<tr><td>Australia</td><td>Early Years Learning Framework V2.0; Australian Curriculum v9 Foundation</td></tr>
<tr><td>Europe (example: Ireland)</td><td>Aistear: Communicating; Exploring &amp; Thinking; Well-being; Identity &amp; Belonging</td></tr>
</table>

<h2>The parental gate</h2>
<p>Grown-up areas (settings, reports, purchases, extra time, adding a child) open only after tapping numbers that are written as words, for example "seven · two · nine". The numbers change every time.</p>

<h2>Accessibility</h2>
<ul>
<li>Every instruction is spoken aloud and shown as a caption.</li>
<li>Large touch targets (64 points or more), left-handed mode, slow narration, reduce motion, and support for larger system text.</li>
<li>Colour is never the only cue: shapes, words and icons are used too.</li>
</ul>
</article>
''';

const privacy = '''
<article class="glass prose">
<h1>Privacy Policy</h1>
<p class="meta">Last updated: $updated</p>
<p>Little Explorers is an app for children aged 3 to 6 and their families. We designed it to collect as little as possible. <b>In short: the app does not send any personal information to us or to anyone else.</b></p>

<h2>Information we collect</h2>
<p><b>None from the app.</b> The app does not collect, store on our servers, share or sell any personal information from children or adults. There are no accounts, no ads, no analytics, no tracking, no chat and no location.</p>

<h2>Information stored on your device</h2>
<p>To work, the app keeps the following <b>only on your device</b>:</p>
<ul>
<li>A nickname such as "Explorer 1" (no real name is needed), an age band (3, 4, 5 or 6) and an avatar colour and hat.</li>
<li>Learning progress: levels finished, stars, stickers and answers used to adapt difficulty.</li>
<li>Minutes played per day, and your settings.</li>
</ul>
<p>We never ask for a child's real name, birthday, photo, voice, email address or location.</p>

<h2>Purchases</h2>
<p>Explorer Plus is sold through the Apple App Store or Google Play. Apple or Google handles payment. We never see your card details. The store only tells the app whether a subscription is active.</p>

<h2>Reminders (notifications)</h2>
<p>Optional reminders for grown-ups are <b>off by default</b>. If you turn them on, your device schedules them locally. Nothing is sent to us or to any server, and no notification is ever addressed to your child. You can turn them off in Grown-ups → Settings or in your device settings.</p>

<h2>Spoken narration</h2>
<p>Tiko's voice uses your device's built-in text-to-speech. The app sends only the words to read to that engine on your device.</p>

<h2>Third parties</h2>
<p>The app contains no third-party advertising, analytics or tracking software, and does not use the advertising identifier.</p>

<h2>How long information is kept</h2>
<table>
<tr><th>Information</th><th>Kept</th></tr>
<tr><td>Profiles, progress, stickers, settings</td><td>On your device until you delete a profile, choose "Delete all data", or uninstall the app</td></tr>
<tr><td>Minutes played</td><td>The last 60 days; older days are deleted automatically</td></tr>
<tr><td>Answer history for each skill</td><td>The last 30 answers; older answers are deleted automatically</td></tr>
</table>

<h2>Your choices and rights</h2>
<ul>
<li><b>See your data:</b> Grown-ups → Settings → Export data copies everything stored, as text.</li>
<li><b>Delete your data:</b> Grown-ups → Settings → Delete all data (or remove one child). Uninstalling the app also deletes everything.</li>
<li>Because we hold no data on our servers, there is nothing for us to delete on our side.</li>
</ul>

<h2>Children's privacy laws</h2>
<p>We follow the principles of the US Children's Online Privacy Protection Act (COPPA), the EU and UK GDPR and the UK Age Appropriate Design Code, and the Australian Privacy Act: data minimisation, high-privacy defaults and no nudges to share data. The app follows the Apple Kids Category guidelines and the Google Play Families Policy.</p>

<h2>Support requests (website only)</h2>
<p>If a grown-up contacts us through the <a href="../support/">support page</a>, we store the topic, the messages you write, and optionally the device type and app version. We don't ask for a name or email address. You get a request number and a private code; the code is stored only in scrambled (hashed) form. To prevent spam, a scrambled version of your internet address is kept for 24 hours. Closed requests are deleted automatically 12 months after the last message, or sooner if you ask us in the request.</p>

<h2>Changes</h2>
<p>If this policy changes, we will update this page and the date above, and describe the change in the app's release notes. We will never start collecting children's data without verifiable parental consent.</p>

<h2>Contact</h2>
<p>Questions about privacy? Contact us with the form on the <a href="../support/">support page</a>.</p>
</article>
''';

const terms = '''
<article class="glass prose">
<h1>Terms of Use</h1>
<p class="meta">Last updated: $updated</p>

<h2>The app</h2>
<p>Little Explorers is an educational app for children aged 3 to 6, used with a parent or carer. The free version includes the daily adventure and the first level of each world. Explorer Plus unlocks every level.</p>

<h2>Subscriptions (Explorer Plus)</h2>
<ul>
<li>Explorer Plus is an <b>auto-renewing subscription</b>, available as <b>Yearly (12 months)</b> or <b>Monthly (1 month)</b>, each with a <b>7-day free trial</b>. Prices are shown in the app before you buy and may differ by country.</li>
<li>Payment is charged to your Apple ID or Google Play account when the free trial ends.</li>
<li>The subscription <b>renews automatically</b> unless it is cancelled at least 24 hours before the end of the current period. Your account is charged for renewal within 24 hours before the end of the current period.</li>
<li>Manage or cancel any time in your account settings: on iPhone or iPad, Settings → your name → Subscriptions; on Android, Google Play → Payments &amp; subscriptions → Subscriptions. Deleting the app does not cancel a subscription.</li>
<li>Any unused part of a free trial ends when you buy a subscription. Refunds are handled by Apple or Google under their policies.</li>
<li>Use "Restore purchases" in the app to restore Explorer Plus on a new device.</li>
</ul>

<h2>Apple users</h2>
<p>If you downloaded the app from the App Store, Apple's standard <a href="https://www.apple.com/legal/internet-services/itunes/dev/stdeula/">Licensed Application End User License Agreement</a> also applies.</p>

<h2>Educational content</h2>
<p>Lessons support (but are not certified by) the early-learning frameworks shown in the Learning Report. They do not replace a teacher, preschool or school assessment.</p>

<h2>Acceptable use</h2>
<p>Please use the app for personal, non-commercial family use. All characters, stories, art and audio are original and owned by Little Explorers.</p>

<h2>Privacy</h2>
<p>See our <a href="../privacy/">Privacy Policy</a>. Everything is stored on your device.</p>

<h2>Contact</h2>
<p>Questions? Visit the <a href="../support/">support page</a>.</p>
</article>
''';

const support = '''
<article class="glass prose">
<h1>Support</h1>
<p>We're happy to help. Many answers are in the questions below. To ask us something, use the form. You'll get a request number and a private code to check our reply here. No email address or account is needed.</p>

<h2 id="contact-us">Contact us</h2>
<form id="contact" class="form" novalidate>
  <div class="row2">
    <label>Topic
      <select name="topic" required>
        <option>Using the app</option>
        <option>Subscription and billing</option>
        <option>Something is not working</option>
        <option>Privacy and data</option>
        <option>Learning content</option>
        <option>Other</option>
      </select>
    </label>
    <label>Device
      <select name="platform">
        <option value="">Choose (optional)</option>
        <option>iPhone</option><option>iPad</option><option>Android phone</option><option>Android tablet</option><option>Other</option>
      </select>
    </label>
  </div>
  <label>App version (optional)
    <input name="appVersion" maxlength="20" placeholder="For example 1.5.0 (Grown-ups → Settings)" autocomplete="off">
  </label>
  <label>Your message
    <textarea name="message" required minlength="10" maxlength="2000" placeholder="Tell us what happened. Please don't include your child's name or other personal details."></textarea>
  </label>
  <div class="hp" aria-hidden="true"><label>Leave this empty <input name="website" tabindex="-1" autocomplete="off"></label></div>
  <div class="actions"><button class="btn" type="submit">Send</button><p id="contact-status" class="notice" hidden></p></div>
</form>
<div id="ticket-made" class="made" hidden>
  <h3>Thank you! We've got your message.</h3>
  <p>Save these to check our reply (we usually answer within 2 working days):</p>
  <p>Request number: <span id="made-id" class="code"></span><br>Private code: <span id="made-code" class="code"></span></p>
  <p>This browser also remembers them for you.</p>
</div>

<h2 id="check">Check a request</h2>
<form id="lookup" class="form">
  <div class="row2">
    <label>Request number <input id="lookup-id" placeholder="LE-XXXXXX" autocomplete="off" autocapitalize="characters"></label>
    <label>Private code <input id="lookup-code" placeholder="8 letters and numbers" autocomplete="off" autocapitalize="characters"></label>
  </div>
  <div class="actions"><button class="btn ghost" type="submit">Check for a reply</button><p id="lookup-status" class="notice" hidden></p></div>
</form>
<section id="thread" class="glass made" hidden aria-live="polite">
  <p class="muted" style="margin:0 0 6px;font-size:.9rem">Keep this page open: our reply appears here by itself.</p>
  <div class="actions"><h3 id="thread-title" style="margin:0"></h3><span id="thread-status" class="pill-status"></span></div>
  <ul id="thread-messages" class="messages"></ul>
  <form id="followup" class="form">
    <label>Add a message <textarea name="message" required maxlength="2000" style="min-height:90px"></textarea></label>
    <div class="actions"><button class="btn" type="submit">Send</button><p id="followup-status" class="notice" hidden></p></div>
  </form>
</section>

<h2>Frequently asked questions</h2>
<details class="glass"><summary>How do I open the grown-ups area?</summary><p>Tap "Grown-ups" on the Home screen, then tap the numbers shown as words (for example "seven · two · nine"). The numbers change every time.</p></details>
<details class="glass"><summary>How do I cancel my subscription?</summary><p>iPhone or iPad: Settings → your name → Subscriptions → Little Explorers → Cancel. Android: Google Play → Payments &amp; subscriptions → Subscriptions → Little Explorers → Cancel. Cancel at least 24 hours before the trial or period ends. Deleting the app does not cancel it.</p></details>
<details class="glass"><summary>How do I restore my purchase on a new device?</summary><p>Grown-ups → Explorer Plus → Restore purchases. Use the same Apple ID or Google account you bought with.</p></details>
<details class="glass"><summary>How do I delete my child's data?</summary><p>Grown-ups → Settings → Children → remove a child, or Grown-ups → Settings → Delete all data. Uninstalling the app also deletes everything. We keep no copy on our servers.</p></details>
<details class="glass"><summary>Tiko isn't speaking. What can I do?</summary><p>Turn up the media volume and check that "Narration" is on in Grown-ups → Settings. The app uses your device's text-to-speech voice: on Android check Settings → Accessibility → Text-to-speech; on iPhone or iPad check Settings → Accessibility → Spoken Content → Voices.</p></details>
<details class="glass"><summary>How do I change the daily time or bedtime lock?</summary><p>Grown-ups → Settings → Time. Choose the adventure length (15, 30, 45 or 60 minutes), the daily limit (30 to 90 minutes) and the bedtime lock.</p></details>
<details class="glass"><summary>How do I turn reminders on or off?</summary><p>Grown-ups → Settings → Reminders for grown-ups. Turn on the daily adventure reminder and pick a time (3 pm to 6 pm). Your device will ask for permission the first time. Turn it off there, or in your device's notification settings.</p></details>
<details class="glass"><summary>What do the two new worlds teach?</summary><p>Word Garden builds vocabulary: naming things, opposites, colours, groups and what things are for. Healthy Me covers handwashing and teeth, healthy food, staying safe, body parts, calming big feelings, daily routines and days of the week.</p></details>
<details class="glass"><summary>Does it work without the internet?</summary><p>Yes. Everything works offline once installed. The internet is only needed to buy or restore a subscription.</p></details>
<details class="glass"><summary>Can siblings use one device?</summary><p>Yes. Add up to 4 child profiles, each with their own progress (Grown-ups → Add).</p></details>

<h2>Requirements</h2>
<table>
<tr><th>Device</th><th>Needs</th></tr>
<tr><td>iPhone and iPad</td><td>iOS / iPadOS 15 or later. Full iPad support, all orientations, Split View and Stage Manager.</td></tr>
<tr><td>Android phones and tablets</td><td>Android 7.0 or later</td></tr>
</table>

<h2>Accessibility</h2>
<p>Narration with captions, large touch targets, left-handed mode, slow narration, reduce motion, and larger system text. If something is hard to use, please tell us with the contact form above.</p>
</article>
''';


void main() {
  final out = Directory('website');
  if (out.existsSync()) out.deleteSync(recursive: true);
  Directory('website/assets').createSync(recursive: true);
  File('website/assets/site.css').writeAsStringSync(css);
  // Cache-busting: every change to styles or scripts gets a new version, so
  // phones always load the newest design without a manual refresh.
  final sources = [css, for (final f in ['support.js', 'admin.js', 'admin.css', 'admin.html']) File('tool/site/$f').readAsStringSync()];
  var h = 0;
  for (final c in sources.join().codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  assetVersion = h.toRadixString(36);
  void write(String slug, String title, String desc, String body, {String head = '', String scripts = ''}) {
    final f = File(slug.isEmpty ? 'website/index.html' : 'website/$slug/index.html');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(page(slug, title, desc, body, head: head, scripts: scripts));
  }

  write('', '$appName: learning app for ages 3–6', 'A calm, ad-free learning adventure for children aged 3 to 6.', home);
  write('parents', 'For parents · $appName', 'How Little Explorers teaches, and how it keeps children safe.', parents);
  write('privacy', 'Privacy Policy · $appName', 'Little Explorers collects no personal information.', privacy);
  write('terms', 'Terms of Use · $appName', 'Terms of use and subscription terms for Little Explorers.', terms);
  write('support', 'Support · $appName', 'Help, FAQs and contact for Little Explorers.', support,
      scripts: '<script src="../assets/support.js?v=$assetVersion" defer></script>');
  // The Support Desk is a stand-alone admin app (its own page, design and menu).
  Directory('website/admin').createSync(recursive: true);
  File('website/admin/index.html').writeAsStringSync(File('tool/site/admin.html')
      .readAsStringSync()
      .replaceAll('{{OWL}}', owl)
      .replaceAll('{{V}}', assetVersion));
  for (final f in ['support.js', 'admin.js', 'admin.css']) {
    File('tool/site/$f').copySync('website/assets/$f');
  }
  File('website/robots.txt').writeAsStringSync('User-agent: *\nDisallow: /admin/\n');
  // Cloudflare headers: fresh HTML, cached assets, admin never cached or framed.
  File('website/_headers').writeAsStringSync('''
/*
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
/assets/*
  Cache-Control: public, max-age=86400
/admin/*
  Cache-Control: no-store
  X-Frame-Options: DENY
''');
  File('website/404.html').writeAsStringSync(page('404', 'Page not found · $appName', 'Page not found',
      '<article class="glass prose" style="text-align:center"><h1>Page not found</h1><p>Let\'s go back to the start.</p><a class="btn" id="home" href="/">Home</a><script>if(location.pathname.indexOf("/little-explorers")===0)document.getElementById("home").href="/little-explorers/"</script></article>'));
  // Copy the icon and a few screenshots.
  File('assets/icon/icon.png').copySync('website/assets/icon.png');
  const shots = {'05_home': 'home', '12_shapes': 'add', '32_number_order': 'order', '17_reward': 'reward', '22_parent': 'parent'};
  shots.forEach((src, dst) {
    final f = File('build/screenshots/web/$src.png');
    if (f.existsSync()) f.copySync('website/assets/shot-$dst.png');
  });
  File('website/.nojekyll').writeAsStringSync('');
  stdout.writeln('Website written to website/');
}
