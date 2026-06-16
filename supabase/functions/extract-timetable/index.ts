// Supabase Edge Function: extract-timetable
//
// Proxies a timetable image/PDF to Google Gemini (gemini-2.5-flash) and returns
// ONLY the parsed JSON to the Flutter app. The Gemini API key lives here as a
// secret env var (GEMINI_API_KEY) and is NEVER shipped in the mobile binary.
//
// Deploy:
//   supabase functions deploy extract-timetable --no-verify-jwt
// Secret:
//   supabase secrets set GEMINI_API_KEY=your_key_here
//
// The app still sends the project's public anon key as a Bearer token (safe to
// embed); `--no-verify-jwt` means we don't require a signed-in user.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const GEMINI_MODEL = "gemini-2.5-flash";
const GEMINI_URL =
  `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

// The exact extraction instruction sent to Gemini as the system prompt.
const EXTRACTION_PROMPT = `You are a timetable extraction engine. You will be given an image or PDF of a
university/college class timetable in any format. Extract it into the EXACT JSON
schema below. Rules:
- Output ONLY valid JSON. No markdown, no explanation, no backticks.
- Use 24-hour HH:MM time format.
- If a cell is a lab spanning multiple periods, set "type":"lab" and repeat it
  across the slots it covers.
- If a value is missing or unreadable, use null. Never invent data.
- Map every day present in the timetable. Include Saturday only if it has classes.
- "faculty" = teacher name or initials if shown, else null.
- "room" = room/hall number if shown, else null.

Schema:
{
  "institution": string | null,
  "department": string | null,
  "semester": string | null,
  "section": string | null,
  "working_days": [string],
  "time_slots": [
    { "index": int, "start": "HH:MM", "end": "HH:MM" }
  ],
  "schedule": {
    "<DayName>": [
      {
        "slot_index": int,
        "subject": string | null,
        "faculty": string | null,
        "room": string | null,
        "type": "lecture" | "lab" | "break" | "free"
      }
    ]
  }
}`;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// Accepted inline mime types.
const ALLOWED_MIME = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/heic",
  "image/heif",
  "application/pdf",
]);

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) {
    // Misconfiguration — never leak details, just signal it's our side.
    return json({ error: "server_misconfigured" }, 500);
  }

  // ---- Parse + validate the request body --------------------------------
  let payload: { mime?: string; data?: string };
  try {
    payload = await req.json();
  } catch (_) {
    return json({ error: "invalid_request", message: "Body must be JSON." }, 400);
  }

  const mime = (payload.mime ?? "").toLowerCase();
  const data = payload.data ?? "";
  if (!data || typeof data !== "string") {
    return json(
      { error: "invalid_request", message: "Missing base64 'data'." },
      400,
    );
  }
  if (!ALLOWED_MIME.has(mime)) {
    return json(
      {
        error: "unsupported_type",
        message: "Send a JPG, PNG, WEBP, or PDF.",
      },
      415,
    );
  }
  // Guard against oversize uploads (base64 inflates ~33%). ~8 MB raw cap.
  if (data.length > 11_000_000) {
    return json(
      { error: "too_large", message: "File is too large (max ~8 MB)." },
      413,
    );
  }

  // ---- Call Gemini -------------------------------------------------------
  const geminiBody = {
    system_instruction: { parts: [{ text: EXTRACTION_PROMPT }] },
    contents: [
      { parts: [{ inline_data: { mime_type: mime, data } }] },
    ],
    generationConfig: {
      temperature: 0,
      responseMimeType: "application/json",
    },
  };

  let res: Response;
  try {
    res = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(geminiBody),
    });
  } catch (_) {
    return json({ error: "upstream_unreachable" }, 502);
  }

  if (res.status === 429) {
    return json(
      {
        error: "rate_limited",
        message: "Gemini is rate-limited. Try again in a minute.",
      },
      429,
    );
  }
  if (!res.ok) {
    // Don't forward Gemini's raw error (may include key hints).
    return json({ error: "upstream_error", status: res.status }, 502);
  }

  let gemini: unknown;
  try {
    gemini = await res.json();
  } catch (_) {
    return json({ error: "bad_upstream_response" }, 502);
  }

  // ---- Extract the model's text and parse it as JSON --------------------
  // deno-lint-ignore no-explicit-any
  const g = gemini as any;
  const finishReason = g?.candidates?.[0]?.finishReason;
  const text: string | undefined =
    g?.candidates?.[0]?.content?.parts
      ?.map((p: { text?: string }) => p?.text ?? "")
      .join("") ?? undefined;

  if (!text || !text.trim()) {
    // Blocked (safety), empty image, or nothing readable.
    return json(
      {
        error: "no_content",
        message:
          finishReason === "SAFETY"
            ? "The image was rejected. Try a clearer photo."
            : "Couldn't read a timetable in that file.",
      },
      422,
    );
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(stripFences(text));
  } catch (_) {
    return json(
      {
        error: "malformed_json",
        message: "The model didn't return valid timetable data. Try again.",
      },
      422,
    );
  }

  // Success: return ONLY the parsed timetable JSON.
  return json(parsed, 200);
});

// Defensive: strip ```json fences if the model ignores responseMimeType.
function stripFences(s: string): string {
  const t = s.trim();
  if (t.startsWith("```")) {
    return t.replace(/^```(?:json)?\s*/i, "").replace(/```\s*$/i, "").trim();
  }
  return t;
}
