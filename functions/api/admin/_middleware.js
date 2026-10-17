import { json, limited, safeEqual } from '../../_lib.js';

// Every /api/admin request needs the admin password (Authorization: Bearer).
// Admin calls are only accepted from the Cloudflare site itself.
export async function onRequest(context) {
  const { request, env } = context;
  if (!env.ADMIN_PASSWORD || env.ADMIN_PASSWORD.length < 10) {
    return json(request, { error: 'The admin password has not been set up yet.' }, 503);
  }
  const origin = request.headers.get('origin');
  if (origin && origin !== new URL(request.url).origin) return json(request, { error: 'Not allowed.' }, 403);
  const auth = request.headers.get('authorization') || '';
  const given = auth.startsWith('Bearer ') ? auth.slice(7) : '';
  if (!safeEqual(given, env.ADMIN_PASSWORD)) {
    if (await limited(env, request, 'adminfail', 10, 900)) {
      return json(request, { error: 'Too many wrong passwords. Please wait 15 minutes.' }, 429);
    }
    return json(request, { error: 'Wrong password.' }, 401);
  }
  return context.next();
}
