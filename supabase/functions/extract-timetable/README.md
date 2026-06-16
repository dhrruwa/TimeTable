# extract-timetable — Gemini timetable OCR proxy

A Supabase Edge Function that takes a base64 image/PDF of a college timetable,
sends it to Google Gemini (`gemini-2.5-flash`), and returns ONLY the parsed JSON.

The Gemini API key lives here as a **secret env var** and is never shipped in the
Flutter app (it could be extracted from the APK/IPA).

## One-time setup

```bash
# 1. Install the Supabase CLI (if needed)
brew install supabase/tap/supabase

# 2. Log in and link this repo to the existing project
supabase login
supabase link --project-ref ocfdldqamonkndutuevd

# 3. Store the Gemini key as a secret (get one free at https://aistudio.google.com/apikey)
supabase secrets set GEMINI_API_KEY=your_gemini_key_here

# 4. Deploy. --no-verify-jwt because the app calls it without a signed-in user;
#    the public anon key (sent as a Bearer token) is the only gate.
supabase functions deploy extract-timetable --no-verify-jwt
```

The function URL will be:
`https://ocfdldqamonkndutuevd.supabase.co/functions/v1/extract-timetable`

## Request / response

**Request** (POST, JSON):
```json
{ "mime": "image/jpeg", "data": "<base64 bytes>" }
```
Headers: `Authorization: Bearer <SUPABASE_ANON_KEY>` and `apikey: <SUPABASE_ANON_KEY>`.

**Success (200):** the parsed timetable JSON (the exact schema in the prompt).

**Errors:** JSON `{ "error": "...", "message": "..." }` with status:
- `429 rate_limited` — Gemini free-tier limit hit; retry shortly.
- `413 too_large` — file over ~8 MB.
- `415 unsupported_type` — not a JPG/PNG/WEBP/PDF.
- `422 no_content` / `malformed_json` — couldn't read a timetable.
- `502` — Gemini unreachable / upstream error.
- `500 server_misconfigured` — `GEMINI_API_KEY` secret missing.

## Local test

```bash
supabase functions serve extract-timetable --env-file ./supabase/.env.local --no-verify-jwt
# then POST a base64 image to http://localhost:54321/functions/v1/extract-timetable
```

## Flutter side

The app reads the URL + anon key from `--dart-define`s (see
`lib/data/timetable_import_service.dart`). The anon key is **public** and safe to
embed — RLS protects your tables, and this function exposes no table access. Run:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://ocfdldqamonkndutuevd.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

> ⚠️ Never pass `GEMINI_API_KEY` to the Flutter app. It belongs only in
> `supabase secrets`.
