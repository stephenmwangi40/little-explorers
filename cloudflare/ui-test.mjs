// Real-browser tests of the website, support page and Support Desk admin,
// against the local copy started by test-api.sh. Runs in CI before deploy.
import { chromium } from 'playwright';

const BASE = 'http://127.0.0.1:8788';
const PASS = 'local-test-password-only';
const pages = ['/', '/parents/', '/privacy/', '/terms/', '/support/', '/admin/'];
const widths = [320, 360, 375, 390, 414, 600, 768, 820, 1024, 1280, 1440, 1920];
let failures = 0;
const fail = (m) => { failures++; console.log('FAIL: ' + m); };
const ok = (m) => console.log('ok  ' + m);

const browser = await chromium.launch();

async function overflow(page, w) {
  return page.evaluate((w) => document.documentElement.scrollWidth > w + 1, w);
}

// 1. Every page fits every screen width (no sideways scrolling).
{
  const page = await browser.newPage();
  for (const p of pages) {
    for (const w of widths) {
      await page.setViewportSize({ width: w, height: 900 });
      await page.goto(BASE + p, { waitUntil: 'load' });
      if (await overflow(page, w)) fail(`${p} overflows at ${w}px`);
    }
  }
  ok(`${pages.length} pages fit ${widths.length} widths`);
  // Live resize without reloading: phone -> desktop -> phone.
  for (const p of pages) {
    await page.setViewportSize({ width: 375, height: 800 });
    await page.goto(BASE + p, { waitUntil: 'load' });
    for (const w of [1280, 820, 375, 1920, 360]) {
      await page.setViewportSize({ width: w, height: 800 });
      await page.waitForTimeout(150);
      if (await overflow(page, w)) fail(`${p} overflows after live resize to ${w}px`);
    }
  }
  ok('pages re-fit live when the screen size changes (no refresh)');
  // Phone menu opens; menu sheet hides itself on a wide screen.
  await page.setViewportSize({ width: 375, height: 800 });
  await page.goto(BASE + '/', { waitUntil: 'load' });
  await page.click('button.menu');
  if (!(await page.isVisible('#sheet'))) fail('phone menu did not open');
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.waitForTimeout(150);
  if (await page.isVisible('#sheet')) fail('phone menu still showing on desktop');
  if (!(await page.isVisible('nav'))) fail('desktop menu not showing');
  ok('menus switch between phone and desktop');
  await page.close();
}

// 2. A parent sends a request and keeps the page open.
const parent = await browser.newPage({ viewport: { width: 375, height: 812 } });
await parent.goto(BASE + '/support/', { waitUntil: 'load' });
await parent.selectOption('#contact select[name=topic]', 'Subscription and billing');
await parent.selectOption('#contact select[name=platform]', 'iPhone');
await parent.fill('#contact textarea[name=message]', 'Browser test: how do I cancel the trial?');
await parent.click('#contact button[type=submit]');
await parent.waitForSelector('#ticket-made:not([hidden])', { timeout: 10000 });
const id = (await parent.textContent('#made-id')).trim();
const code = (await parent.textContent('#made-code')).trim();
if (!/^LE-[A-Z0-9]{6}$/.test(id) || !/^[A-Z0-9]{8}$/.test(code)) fail(`bad request number/code ${id}`);
await parent.click('#lookup button[type=submit]');
await parent.waitForSelector('#thread:not([hidden])', { timeout: 10000 });
if ((await parent.textContent('#thread-status')).trim() !== 'Waiting for our reply') fail('parent status wrong');
ok(`parent opened ${id} and sees it waiting`);

// 3. Admin on a phone: sign in, find the request, reply, go Home.
const admin = await browser.newPage({ viewport: { width: 375, height: 812 } });
await admin.goto(BASE + '/admin/', { waitUntil: 'load' });
if (await admin.$('nav')) fail('admin page shows the public website menu');
if (await admin.$('a[href*="privacy"]')) fail('admin page links to public pages');
await admin.fill('#password', 'wrong-password-here');
await admin.click('#login button[type=submit]');
await admin.waitForSelector('#login-status:not([hidden])');
if (!(await admin.isHidden('#app'))) fail('wrong password let admin in');
await admin.fill('#password', PASS);
await admin.click('#login button[type=submit]');
await admin.waitForSelector('#app:not([hidden])', { timeout: 10000 });
ok('admin rejects wrong password, accepts the right one');
if (!(await admin.isVisible('#home-btn'))) fail('Home button not visible on phone');
if (await overflow(admin, 375)) fail('admin overflows on phone');
await admin.click('[data-filter="unread"]');
await admin.waitForSelector(`.ticket:has-text("${id}")`, { timeout: 10000 });
await admin.click(`.ticket:has-text("${id}")`);
await admin.waitForSelector('#detail:not([hidden])');
if ((await admin.getAttribute('#layout', 'data-view')) !== 'detail') fail('phone did not switch to conversation view');
if (!(await admin.isHidden('.list-pane'))) fail('list still showing behind conversation on phone');
await admin.click('[data-template]');
await admin.click('#reply button[type=submit]');
await admin.waitForSelector('#d-status-msg.ok', { timeout: 10000 });
if (!(await admin.textContent('#d-status')).includes('answered')) fail('reply did not mark answered');
ok('admin replied with a quick reply on a phone');
await admin.click('#home-btn');
if ((await admin.getAttribute('#layout', 'data-view')) !== 'home') fail('Home did not return to the list');
if (!(await admin.isVisible('.list-pane'))) fail('list not visible after Home');
ok('Home button returns to the list');
// Live resize to desktop: two columns, no reload.
await admin.click(`.ticket:has-text("${id}")`);
await admin.setViewportSize({ width: 1280, height: 800 });
await admin.waitForTimeout(200);
if (!(await admin.isVisible('.list-pane')) || !(await admin.isVisible('#detail'))) fail('desktop should show list and conversation together');
if (await overflow(admin, 1280)) fail('admin overflows on desktop');
ok('admin re-arranges live from phone to desktop');

// 4. The parent sees the reply appear without refreshing.
try {
  await parent.waitForSelector('#thread-messages li.support', { timeout: 30000 });
  ok('parent saw the reply appear by itself');
} catch {
  fail('reply did not appear on the parent page without a refresh');
}

// 5. Admin closes and signs out.
await admin.click('#close');
await admin.waitForSelector('#reopen:not([hidden])');
await admin.click('#signout');
if (!(await admin.isVisible('#login'))) fail('sign out did not return to sign in');
ok('admin closed the request and signed out');

await browser.close();
if (failures) {
  console.log(`${failures} UI test(s) failed`);
  process.exit(1);
}
console.log('ALL BROWSER TESTS PASSED');
