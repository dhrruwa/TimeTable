# Timetable (Phase 1)

A local-only college class timetable app for Android and iOS. Students build a
weekly, repeating class schedule (no dates, no odd/even weeks) and see what's on
now and next.

This is **Phase 1**: fully runnable, local-only. No cloud/share backend and no
native home-screen widget yet — but the architecture is layered so those slot in
without refactoring.

## Setup

This repo contains the full Dart source. Two generated/scaffolded pieces are
produced by the Flutter toolchain on your machine (they're intentionally
gitignored):

```bash
# 1. Generate the native platform folders (android/, ios/) without touching lib/.
flutter create --platforms=android,ios .

# 2. Fetch dependencies.
flutter pub get

# 3. Generate the Isar entity code (creates lib/data/isar_entities.g.dart).
dart run build_runner build --delete-conflicting-outputs

# 4. Run it.
flutter run                 # Android device, or
flutter run -d "iPhone 15"  # iOS simulator
```

Sample courses and classes are seeded on first launch so the UI is populated
immediately.

Run the logic tests (pure Dart, no device needed):

```bash
flutter test
```

## Architecture

Clean separation so Phase 2 (cloud) and Phase 3 (widget) drop in cleanly:

| Layer        | Folder            | Responsibility                                              |
| ------------ | ----------------- | ----------------------------------------------------------- |
| Models       | `lib/models`      | Pure data + JSON. **No Flutter/Isar imports.**              |
| Logic        | `lib/logic`       | `ScheduleService` — the single source of truth for now/next. **Pure Dart.** |
| Persistence  | `lib/data`        | Isar mirror entities + repository (`TimetableRepository`).   |
| Providers    | `lib/providers`   | Riverpod wiring; mutate-and-persist.                         |
| UI           | `lib/screens`, `lib/widgets` | Material 3 screens & widgets. Read schedule answers only from `ScheduleService`. |

Key design rules honored:

- **`ScheduleService` is pure** — no Flutter, no Isar, no persistence. All
  "what's now / what's next" logic lives there; the UI never recomputes it.
- **Domain models keep their `toJson`/`fromJson` intact** for Phase 2 cloud
  sharing. Isar uses *mirror entities* in `lib/data` rather than annotating the
  models, so the serialization format stays untouched.
- **Repository is an interface** (`TimetableRepository`); the Isar implementation
  is swappable for a future cloud-backed one.

## Screens

1. **Today** (default tab) — live banner (in-progress class, else "next in X
   min"), then today's color-coded classes with the current one highlighted.
2. **Week** — Mon–Sat grid (Sunday toggle), color-coded blocks; tap to edit.
3. **Courses** — add / edit / delete; deleting a course with slots confirms first.
4. **Add/Edit class** — pick course (or quick-add inline), day, start/end via
   native time pickers. Built to add a class in under 15 seconds.
5. **Add/Edit course** — name, optional instructor/room, color picker.

Full dark mode (system default + manual toggle in the Today app bar).

## Phase 2 / 3 hooks

- **Cloud share:** implement `TimetableRepository` against your backend and swap
  the override in `main.dart`. `Timetable.toJsonString()` is the wire format.
- **Home-screen widget:** `ScheduleService.widgetTimelineForDay()` already
  returns a current/next-annotated timeline ready to feed a native widget.
