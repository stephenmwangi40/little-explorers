#!/usr/bin/env bash
# End-to-end test of the support system against a LOCAL copy of the site
# (wrangler pages dev, local D1). Runs in CI before every deploy.
set -euo pipefail

BASE=http://127.0.0.1:8788
PASS=local-test-password-only
ORIGIN=https://little-explorers-app.pages.dev

npx --yes wrangler@4 d1 execute little-explorers-support --local --file=cloudflare/schema.sql >/dev/null
npx --yes wrangler@4 pages dev --port 8788 --binding ADMIN_PASSWORD=$PASS >/tmp/pages-dev.log 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null || true' EXIT
for i in $(seq 1 60); do curl -sf $BASE/ >/dev/null && break; sleep 1; done

fail() { echo "FAIL: $1"; echo "--- server log ---"; tail -40 /tmp/pages-dev.log; exit 1; }
field() { python3 -c "import sys,json;print(json.load(sys.stdin).get('$1',''))"; }

echo "1. Pages are served"
for p in / /support/ /privacy/ /admin/ /assets/support.js /assets/admin.js; do
  code=$(curl -s -o /dev/null -w '%{http_code}' $BASE$p); [ "$code" = 200 ] || fail "$p returned $code"
done

echo "2. Bad requests are refused"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST $BASE/api/tickets -H 'content-type: application/json' -d '{"topic":"Other","platform":"","message":"short"}')
[ "$code" = 400 ] || fail "short message accepted ($code)"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST $BASE/api/tickets -H 'content-type: application/json' -d '{"topic":"Nope","platform":"","message":"A long enough message here"}')
[ "$code" = 400 ] || fail "bad topic accepted ($code)"
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST $BASE/api/tickets -H 'content-type: application/json' -d '{"topic":"Other","platform":"","message":"A long enough message here","website":"spam"}')
[ "$code" = 400 ] || fail "spam trap ignored ($code)"

echo "3. A parent opens a request"
out=$(curl -s -X POST $BASE/api/tickets -H 'content-type: application/json' -H "origin: $ORIGIN" \
  -d '{"topic":"Using the app","platform":"iPad","appVersion":"1.4.0","message":"Tiko does not speak on my iPad."}')
ID=$(echo "$out" | field id); CODE=$(echo "$out" | field code)
[[ "$ID" =~ ^LE-[A-Z0-9]{6}$ ]] || fail "bad id: $out"
[[ "$CODE" =~ ^[A-Z0-9]{8}$ ]] || fail "bad code: $out"

echo "4. The parent can see it only with the right code"
code=$(curl -s -o /dev/null -w '%{http_code}' $BASE/api/tickets/$ID -H 'x-ticket-code: WRONGCOD')
[ "$code" = 404 ] || fail "wrong code accepted ($code)"
st=$(curl -s $BASE/api/tickets/$ID -H "x-ticket-code: $CODE" | field status)
[ "$st" = open ] || fail "status should be open, got $st"

echo "5. Admin needs the password"
code=$(curl -s -o /dev/null -w '%{http_code}' $BASE/api/admin/tickets)
[ "$code" = 401 ] || fail "admin without password returned $code"
code=$(curl -s -o /dev/null -w '%{http_code}' $BASE/api/admin/tickets -H 'authorization: Bearer wrong-password')
[ "$code" = 401 ] || fail "admin with wrong password returned $code"

echo "6. Admin sees the request and replies"
list=$(curl -s "$BASE/api/admin/tickets?status=open" -H "authorization: Bearer $PASS")
echo "$list" | grep -q "$ID" || fail "admin list missing ticket: $list"
echo "$list" | grep -q '"unread":1' || fail "unread count wrong: $list"
curl -s $BASE/api/admin/tickets/$ID -H "authorization: Bearer $PASS" | grep -q 'Tiko does not speak' || fail "admin detail missing message"
st=$(curl -s -X POST $BASE/api/admin/tickets/$ID -H "authorization: Bearer $PASS" -H 'content-type: application/json' \
  -d '{"action":"reply","message":"Please turn on Narration in Grown-ups, Settings."}' | field status)
[ "$st" = answered ] || fail "reply did not mark answered ($st)"

echo "7. The parent sees the reply and follows up"
t=$(curl -s $BASE/api/tickets/$ID -H "x-ticket-code: $CODE")
echo "$t" | grep -q '"author":"support"' || fail "parent cannot see reply: $t"
echo "$t" | grep -q 'turn on Narration' || fail "reply text missing"
st=$(curl -s -X POST $BASE/api/tickets/$ID -H "x-ticket-code: $CODE" -H 'content-type: application/json' -d '{"message":"Thank you, it works now!"}' | field status)
[ "$st" = open ] || fail "follow-up should reopen ($st)"

echo "8. Admin closes, reopens and deletes"
st=$(curl -s -X POST $BASE/api/admin/tickets/$ID -H "authorization: Bearer $PASS" -H 'content-type: application/json' -d '{"action":"close"}' | field status)
[ "$st" = closed ] || fail "close failed ($st)"
st=$(curl -s -X POST $BASE/api/admin/tickets/$ID -H "authorization: Bearer $PASS" -H 'content-type: application/json' -d '{"action":"reopen"}' | field status)
[ "$st" = open ] || fail "reopen failed ($st)"
del=$(curl -s -X POST $BASE/api/admin/tickets/$ID -H "authorization: Bearer $PASS" -H 'content-type: application/json' -d '{"action":"delete"}' | field deleted)
[ "$del" = True ] || fail "delete failed ($del)"
code=$(curl -s -o /dev/null -w '%{http_code}' $BASE/api/tickets/$ID -H "x-ticket-code: $CODE")
[ "$code" = 404 ] || fail "deleted ticket still visible ($code)"

echo "9. Cross-site admin calls are blocked"
code=$(curl -s -o /dev/null -w '%{http_code}' $BASE/api/admin/tickets -H "authorization: Bearer $PASS" -H 'origin: https://evil.example')
[ "$code" = 403 ] || fail "cross-site admin call returned $code"

echo "ALL SUPPORT TESTS PASSED"
