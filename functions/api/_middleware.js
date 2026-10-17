import { cors, json } from '../_lib.js';

// CORS preflight, and a friendly JSON error for anything unexpected.
export async function onRequest(context) {
  if (context.request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: cors(context.request) });
  }
  try {
    return await context.next();
  } catch (e) {
    return json(context.request, { error: 'Something went wrong. Please try again.' }, 500);
  }
}
