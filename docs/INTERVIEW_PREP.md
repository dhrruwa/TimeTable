# Timetable App — Interview Prep Q&A

A complete question bank for talking about this project in an interview. Answers
are written in first person so you can adapt them to how you actually speak.
Skim the **★ one-liner** first, then the detail.

---

## 0. The 30-Second Elevator Pitch

> "It's an offline-first college timetable app built with Flutter. Students can
> build a weekly repeating class schedule, or — the headline feature — just take
> a photo of their printed timetable and an AI vision model extracts it into a
> structured, editable schedule. The app shows a live 'what's on now / what's
> next' view, renders native home-screen widgets on both iOS and Android, and
> lets students share their whole timetable with classmates through a QR code or
> link with no backend at all. There's also a Next.js landing page with an admin
> analytics dashboard. The backend AI is a Supabase Edge Function proxying Google
> Gemini."

**Tech stack:** Flutter / Dart, Riverpod (state), Isar (local DB), Supabase Edge
Functions (Deno/TypeScript), Google Gemini 2.5 Flash (vision), Next.js (web),
home_widget + native WidgetKit (Swift) / AppWidget (Kotlin).

---

## 1. Architecture & Design Decisions

### Q: Walk me through your app's architecture.
**★ Clean layered architecture with a strict dependency direction.**

I have five layers, each in its own folder:

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| Models | `lib/models` | Pure data + JSON. **No Flutter, no Isar imports.** |
| Logic | `lib/logic` | Pure-Dart algorithms — `TodayEngine`, `TimetableBuilder`, `ShareCodec`. |
| Persistence | `lib/data` | Isar entities + repository interfaces. |
| Providers | `lib/providers` | Riverpod wiring; mutate-and-persist. |
| UI | `lib/screens`, `lib/widgets` | Material 3 screens. Read answers only, never recompute. |

The key rule: **dependencies point inward.** The UI depends on logic; logic
depends on models; models depend on nothing. The persistence layer is the only
place that knows about Isar. This is what lets me unit-test the entire scheduling
brain in pure Dart with no device or emulator.

### Q: Why keep the domain models free of Flutter and Isar?
Three reasons:
1. **Testability** — pure Dart logic runs in `flutter test` with no device.
2. **Portability / future cloud** — the same `toJson`/`fromJson` is the wire
   format for sharing and a future cloud backend. If I annotated the models with
   Isar, the serialized shape would be coupled to the DB.
3. **Separation** — I used *mirror entities* in `lib/data` (a separate Isar class
   that just stores the model's JSON) instead of annotating the model directly.
   The model stays clean; persistence is a detail.

### Q: How do you persist the timetable?
The whole timetable is stored as a **single JSON blob in one Isar document**
(`TimetableDocEntity`, fixed `id = 0`). I didn't normalize it into relational
tables because:
- There's only ever one active timetable per device.
- It's small (a week of classes).
- Keeping it as one JSON blob means the model stays pure and the same format is
  reused for sharing.

Every mutation goes through `TimetableNotifier._commit()`, which updates the
Riverpod state **and** writes to Isar in a `writeTxn` — so the UI and disk never
drift apart. There's no manual "save" button.

### Q: Why the Repository pattern if it's just local?
`PeriodRepository` is an abstract interface; `IsarPeriodRepository` is the
implementation. The benefit is **swappability** — I can drop in a mock repo for
tests, or a cloud-backed repo later, without touching the providers or UI. The
provider is injected via a Riverpod `override` in `main.dart`, so the wiring
happens in exactly one place.

---

## 2. The "Now / Next" Algorithm (your core logic — expect deep questions)

### Q: How do you compute what class is on right now?
Two pure functions do everything:

**1. `TimetableBuilder.buildDay()`** turns an *ordered* list of periods into a
concrete timed timeline. The crucial design choice: **periods don't store their
times.** A period only knows its subject, room, teacher, and whether it's a lab.
Times are computed by walking the list with a "cursor" that starts at
`config.dayStartMin` and advances by each period's duration (`classMins`, or
`labMins` for labs), inserting tea/lunch breaks at configured positions.

**2. `TodayEngine.compute(timeline, now)`** finds the current state. I convert
`now` into "minutes since midnight" (`hour * 60 + minute`) and:
- Linear-scan the timeline for the entry where `startMin <= now < endMin` → that's
  the current class.
- Collect entries with `startMin > now` → upcoming classes.
- Completion % is linear interpolation: `(now - startMin) / durationMin`, clamped
  0–1.
- Flags: `beforeDay` (before first class), `dayOver` (after last), `empty`.

It returns an immutable `TodayStatus`, and the UI just reads from it.

### Q: Why store time as "minutes since midnight" instead of DateTime?
It makes the logic **stateless and trivially testable.** `now` collapses to a
single integer, so a test is just `TodayEngine.compute(timeline, DateTime(2026,1,1,8,55))`
and I assert `completionPercent == 50`. No timezones, no date math, no mocking the
clock. The algorithm is also O(n) over a handful of periods — effectively instant.

### Q: Why compute times instead of storing them on each period?
Because it makes **global edits O(1).** If a student wants to shift their whole
day 30 minutes earlier, or change class length from 50 to 55 minutes, I change one
field in `TimetableConfig` and every time recomputes. If times were baked into
each period I'd have to migrate every row. It also keeps shared payloads tiny —
I don't transmit times, just the config + ordered periods.

### Q: What's the trade-off of that design?
It assumes a **regular, back-to-back schedule** driven by a global config (fixed
class length, breaks at fixed positions). It doesn't naturally model an irregular
day where, say, period 3 has a random 40-minute gap. I handle that with "Free"
placeholder periods during import, but a fully arbitrary schedule would need
per-period start/end overrides. That's the main limitation and I'd call it out
honestly.

### Q: How is this tested?
`test/timetable_engine_test.dart` covers: sequential time building, lab = 2-hour
block, break insertion, completion % across both a 50-min class and a 120-min lab,
break-hint detection, the day-over state, and defensive handling of orphan periods
(a period whose subject was deleted is skipped, not crashed on).

---

## 3. State Management — Riverpod

### Q: Why Riverpod over Provider / Bloc / setState?
I wanted compile-time-safe dependency injection and fine-grained rebuilds without
boilerplate. Riverpod gives me:
- **`StateNotifierProvider`** for the timetable — a single source of truth where
  every mutation persists.
- **`Provider.family`** — `timelineForDayProvider(weekday)` derives a timeline per
  day and only recomputes when the timetable actually changes.
- **`StreamProvider`** for the clock — a one-minute tick drives the live "now"
  view, plus a `.autoDispose` second-level clock for the progress ring that's only
  alive while the Today screen is visible.
- **Override-based injection** — repositories are injected at the `ProviderScope`
  in `main.dart`, which makes testing and swapping implementations clean.

### Q: How does the UI update every minute without rebuilding everything?
`clockProvider` is a `StreamProvider<DateTime>` that emits immediately, then every
minute. Only widgets that `watch` the derived "now" status rebuild. The expensive
per-second progress animation uses a **separate auto-dispose stream** so its cost
is bounded to when the Today screen is actually on-screen.

---

## 4. AI Timetable Import (the standout feature)

### Q: Walk me through what happens when a user imports a photo.
End-to-end:
1. **Pick** — `file_picker` selects a JPG/PNG/WEBP/PDF.
2. **Preprocess** — `prepareForUpload()` runs in a `compute()` **isolate** (off
   the UI thread) so the app never jank. It downscales to max 1600px, bakes in
   EXIF orientation (so sideways phone photos extract correctly), and re-encodes
   as 85%-quality JPEG. PDFs pass through untouched.
3. **Upload** — base64 + MIME type POSTed to a **Supabase Edge Function**
   (`extract-timetable`), not directly to the AI.
4. **Extract** — the Edge Function calls **Google Gemini 2.5 Flash** with a strict
   system prompt and `responseMimeType: "application/json"`, `temperature: 0`.
5. **Map** — the returned JSON is converted to an editable `DraftTimetable` by
   `ImportMapper`, which *derives the schedule config* from the extracted time
   slots (day start, median period length, break positions).
6. **Review** — the user lands on a review screen to fix anything before saving.
   I never auto-commit AI output.

### Q: Why route through a Supabase Edge Function instead of calling Gemini directly from the app?
**Security and control.** The Gemini API key must never ship inside an APK — it'd
be trivially extractable and abusable. The Edge Function keeps the key server-side,
and it's also where I enforce file-size limits, MIME validation, retry/backoff
logic, and normalize errors into clean status codes. The app only ever holds the
public Supabase anon key, which is safe to ship.

### Q: Why Gemini 2.5 Flash specifically?
It's a fast, cost-effective vision model with native multimodal input (I send the
raw image bytes inline) and structured JSON output. For an OCR-style extraction
task I don't need a frontier reasoning model — Flash is the right cost/latency
point. I set `temperature: 0` for deterministic, repeatable extraction, and force
JSON output so I don't have to parse free text.

### Q: How do you handle the AI being wrong or the image being unreadable?
Several layers:
- **Human-in-the-loop** — output always goes to a review/edit screen first.
- **The prompt forbids invention** — Gemini is told not to hallucinate subjects.
- **Config derivation is defensive** — if the time grid is unreadable it falls
  back to slot-index order and collapses multi-slot labs; readable times get
  "Free" placeholders inserted to preserve later periods' real times.
- **Error mapping** — the function returns `422` when no timetable is found,
  `413` too large, `415` unsupported type, `429` rate-limited, each mapped to a
  friendly message in the app.

### Q: How do you handle transient failures / Gemini overload?
The Edge Function **retries up to 4 times** on 429/500/502/503 with linear backoff
(~0.7s, 1.4s, 2.1s). The app uses a generous 120-second timeout because large PDFs
take longer. It also strips markdown code-fences in case the model wraps JSON
despite the `responseMimeType` setting — a real-world robustness detail.

---

## 5. Serverless Sharing (QR / Deep Links)

### Q: How do students share a timetable with each other?
**The entire timetable is encoded into the share link itself — there's no server.**
`ShareCodec.encode()` does: Timetable → compact JSON → gzip(level 9) → base64url →
URL fragment. The result is a normal HTTPS link (or a `classtimetable://` deep
link). They can send it over WhatsApp, email, anything. The recipient's app
decodes it back into a full timetable.

### Q: A whole timetable in a URL — how do you keep it small enough for a QR code?
A **compact v2 representation**, roughly 3–4× smaller than naive JSON:
- Subjects are stored once in an array and referenced **by index**, not by UUID,
  in each period.
- **UUIDs are dropped entirely** from the wire format and regenerated on import —
  random UUIDs don't compress and were blowing up QR size.
- Fields are positional arrays, not verbose key/value objects.
- Then gzip + base64url on top.

I also pre-validate with `QrValidator` before rendering, so an oversized timetable
shows a fallback message instead of a broken QR.

### Q: How do deep links work?
The `app_links` package handles both cold-start (`getInitialLink()`) and
running-app (`uriLinkStream`) cases. Because a link can arrive when no screen is
mounted, I route through a **global `navigatorKey`** that wraps the whole app. The
URI is decoded by `ShareCodec.tryDecode()` and the user gets a preview screen
before importing. The custom scheme is registered in `AndroidManifest.xml` and
`Info.plist`.

### Q: Isn't a local-only "community" feature fake?
It's honest about being a **local mock that mirrors the real backend's shape.** The
`CommunityRepository` interface + `matchKey` index (normalized
`university|branch|semester|section`) is exactly the query a server would run. The
Isar implementation filters in Dart at small scale; swapping in Supabase/Firebase
later is a drop-in because the interface and data shapes already match. I'd present
it as "Phase 2-ready," not as production multi-device sync.

---

## 6. Home-Screen Widgets (impressive, platform-specific)

### Q: How do the home-screen widgets work?
I render three layouts — small, medium, large — and the approach **differs by
platform**, which is the interesting part:

- **iOS (WidgetKit):** A widget extension runs in a separate process that *can't
  run Dart*. So the Flutter app renders each widget to a **PNG** via
  `HomeWidget.renderFlutterWidget()`, writes the image paths to a shared **App
  Group**, and the Swift `Provider` just loads the images. Flutter owns the look;
  Swift owns the display.
- **Android (AppWidget):** Native Kotlin can compute and draw, so instead of
  images I write the **full day's timeline as JSON** to `SharedPreferences`. Native
  `WidgetRenderer` code reads the JSON and computes the current period **from the
  system clock** on each tick, filling a RemoteViews layout. An `AlarmManager`
  fires a 1-minute repeating tick so the widget stays live **without foregrounding
  the app.**

### Q: Why two completely different approaches?
Platform constraints. iOS widget extensions can't host a Flutter engine, so
pre-rendering to images is the pragmatic path. Android's AppWidget framework *can*
read shared data and redraw natively, which is more efficient and lets the widget
self-update from the clock without waking the Dart side. Using each platform's
strengths beats forcing one uniform approach.

### Q: When do widgets refresh?
App-side, `HomeWidgetUpdater` triggers a refresh on first frame, on app resume, on
every clock tick, and whenever the timetable is edited. But the **OS throttles**
actual home-screen redraws — Android ~30s, iOS ~15min — so I design the widget to
compute "current period" from the clock at draw time rather than relying on the app
pushing every minute.

---

## 7. The Web App (Next.js)

### Q: What's the Next.js app for?
Two things: a **marketing landing page** (hero, features, FAQ, APK download +
email early-access signup) and a **password-protected admin analytics dashboard**.

The admin side shows total APK downloads, derived active-student estimates, a
7-day download growth chart (rendered as inline SVG), recent newsletter signups,
and a support-message inbox. Auth is a SHA-256-hashed session cookie with a 2-hour
TTL, validated against an `ADMIN_PASSWORD` env var. Data lives in Supabase tables
(`downloads`, `newsletter_subscribers`, `support_messages`), with a localStorage /
mock-data fallback when Supabase isn't configured for local dev.

### Q: How is an APK download tracked?
Clicking download calls `trackDownload()`, which inserts a row into the Supabase
`downloads` table (or localStorage as a dev fallback) before the browser fetches
the APK. The admin dashboard counts those rows.

---

## 8. Testing & Quality

### Q: What did you test, and what's your testing philosophy?
I focused tests where the **risk and logic density** are highest — the pure-Dart
brain — rather than chasing coverage on UI glue:
- `timetable_engine_test.dart` — the now/next algorithm, completion %, breaks,
  day-over, orphan handling.
- `share_codec_test.dart` — encode→decode round-trips, real-URL format, tolerance
  for chat noise around a link, and null for non-timetable input.
- `week_screen_smoke_test.dart` — a widget smoke test guarding a past
  "infinite constraints" layout bug in the zoomable grid.

Because the logic layer is pure Dart, all of this runs in `flutter test` with no
device or emulator, so it's fast enough to run on every change. CI is wired in
`.github/workflows/ci.yml`.

---

## 9. Cross-Cutting / "Senior" Questions

### Q: What was the hardest part of this project?
Honestly, the **dual-platform widget rendering.** Getting Flutter to rasterize
widgets to images that look right inside an iOS App Group, while building a
parallel native Android path that recomputes from the clock — and keeping both in
sync with the same `TimetableBuilder` logic — took the most iteration. The
OS-level refresh throttling also forced me to make the widget self-sufficient
rather than app-driven.

### Q: What would you do differently or improve next?
- **Real cloud sync** — replace the mock community repo with Supabase so edits
  propagate across devices and classmates see updates.
- **Irregular schedules** — support per-period time overrides for days that don't
  fit the global config.
- **On-device caching of AI results** and a confidence score surfaced in the review
  screen.
- **Migrate Isar** — Isar 3 is somewhat unmaintained; I'd evaluate Isar 4 or
  drift/sqlite for longevity.

### Q: How would this scale to thousands of users?
The client is already offline-first, so per-user load is trivial. The scaling
pressure is the **Edge Function → Gemini** path: I'd add request quotas per device,
cache identical extractions, and monitor cost. The community feature would move to
Supabase with proper indexes on `matchKey` and row-level security. The share
mechanism needs zero scaling since it's fully serverless.

### Q: How do you keep the Gemini API key and admin safe?
Key never ships in the app — it lives in the Edge Function's secrets. The app holds
only the public anon key. Admin auth is a hashed, HTTP-only, secure, SameSite=strict
session cookie over HTTPS. File-size and MIME validation on the function guard
against abuse.

### Q: Why Flutter over native or React Native?
One codebase for iOS + Android with native performance, and crucially **Flutter's
widget rendering let me reuse the exact same UI components to generate home-screen
widget images** — I didn't have to rebuild the card designs natively for iOS.
Material 3 theming and the strong typed Dart logic layer were also a good fit for
a logic-heavy app.

---

## 10. Rapid-Fire (know these cold)

- **State management?** Riverpod (`StateNotifierProvider`, `Provider.family`, `StreamProvider`).
- **Local DB?** Isar — single JSON-blob document.
- **AI model?** Google Gemini 2.5 Flash, `temperature: 0`, JSON output.
- **Why an Edge Function?** Hide the API key, validate, retry, normalize errors.
- **Sharing transport?** gzip + base64url in a URL fragment — fully serverless.
- **Why no times on periods?** Times derive from a global config → O(1) global edits.
- **"Now" representation?** Minutes since midnight → stateless, testable.
- **iOS widgets?** Flutter renders PNGs → App Group → Swift loads them.
- **Android widgets?** JSON to SharedPreferences → native recompute from clock + AlarmManager.
- **Image preprocessing?** Downscale to 1600px + EXIF bake, in a compute() isolate.
- **Repository pattern?** Swappable interface; Isar now, cloud later.
- **Web app?** Next.js landing + SHA-256-cookie-protected admin analytics on Supabase.
- **Testing?** Pure-Dart logic tests + a widget smoke test, all device-free.

---

### Files to be ready to open
- `lib/logic/today_engine.dart` — the now/next brain
- `lib/logic/timetable_builder.dart` — time sequencing
- `lib/logic/share_codec.dart` — compact encode/decode
- `lib/models/period_models.dart` — all data shapes
- `lib/providers/widget_providers.dart` — state mutations + persistence
- `lib/data/period_repository.dart` — repository contract
- `supabase/functions/extract-timetable/index.ts` — the Gemini proxy
- `lib/screens/magic_import_screen.dart` — AI import UI flow
- `test/timetable_engine_test.dart` — live examples of the algorithm
