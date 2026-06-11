# College Timetable App — Full Build Prompt

You are working inside an existing **Flutter** project (`timetable/`). The project uses:
- **Flutter Riverpod** (`flutter_riverpod`) for state management
- **Isar** for local persistence
- **home_widget** for home-screen widgets
- **share_plus + app_links** for sharing

The existing models, data layer, and providers are already correct. **Do not change `period_models.dart`, `timetable_builder.dart`, `isar_entities.dart`, or `providers.dart`** unless a feature strictly requires it — and if you do, state why.

---

## EXISTING CODEBASE SUMMARY

### Models (`lib/models/period_models.dart`)
- `Subject` — id, name, color (ARGB int)
- `Period` — id, subjectId, room?, teacher?, isLab (bool)
- `TimetableConfig` — dayStartMin, classMins, labMins, teaAfter, teaMins, lunchAfter, lunchMins
- `TimetableMeta` — university, branch, semester, section, creatorName
- `Timetable` — subjects[], week (Map<int,List<Period>> where 1=Mon..6=Sat), config, meta
- `TimelineEntry` — resolved slot with concrete startMin/endMin, color, isClass/isBreak/isLab flags

### Key rules baked into the model
1. Timetable is **period-based**, not time-block based. Times are computed by `TimetableBuilder`.
2. A **theory class = exactly 1 Period** (isLab: false).
3. A **lab = exactly 1 Period** (isLab: true) but occupies 2 consecutive time slots.
4. Labs **cannot cross Tea Break or Lunch Break** — validate on save.
5. Break positions (`teaAfter`, `lunchAfter`) are integers = "insert break after N-th class block."
6. `TimetableConfig` is per-timetable, so different colleges configure independently.

### Providers (`lib/providers/providers.dart`)
- `clockProvider` — Stream<DateTime> ticking every minute
- `nowProvider` — current DateTime (from clockProvider)
- `themeModeProvider` — ThemeMode state
- `timetableProvider` — the full Timetable (from Isar via `widget_providers.dart`)
- `timelineForDayProvider(int weekday)` — List<TimelineEntry> for a day

### Current screens
- `home_screen.dart` — bottom nav shell (Today, Week, Subjects, Settings)
- `today_screen.dart` — today's class list with live "now/next" logic
- `week_screen.dart` — Mon–Sat × P1–Pn grid (already has real-time dates)
- `edit_day_screen.dart` — edit a single day's periods
- `subjects_screen.dart` — manage subjects
- `settings_screen.dart` — configure TimetableConfig
- `share_screen.dart` — share the timetable
- `onboarding_screen.dart` — first-run setup

---

## FEATURES TO BUILD

Build all of the following. Work file-by-file. After each file, show what you changed and why.

---

### FEATURE 1 — Week Screen: Real-time dates + current period highlighting

**File:** `lib/screens/week_screen.dart`

The `_DayLabel` already shows day name + date number + month (this was done). Now add:

1. **"NOW" badge on the current period column header.**
   - Compute `currentPeriodIndex` from `nowProvider` and the config's period times.
   - Show a small filled chip `NOW` above the `P3` text in `_HeaderRow` for today only.
   - If the current time is inside a break, show nothing.

2. **Current subject card gets a glowing ring.**
   - In `_ClassCell`, if this cell is today's current period, add a `BoxShadow` using the subject's color with 40% opacity at 8px blur.
   - Also show a tiny `NOW` badge inside the card (white text on subject color).

3. **Past day rows at 55% opacity.**
   - Already done in `_DayLabel`. Also apply `Opacity(opacity: isPast ? 0.55 : 1.0)` to the entire `_DayRow` for past days (Mon–yesterday).

4. **Week range in AppBar subtitle** — already done (`2 Jun – 7 Jun 2025`). Keep it.

Helper to add inside `WeekScreen`:
```dart
int? _currentPeriodIndex(TimetableConfig cfg, DateTime now) {
  final hhmm = now.hour * 60 + now.minute;
  // Build the period start/end times using the same logic as TimetableBuilder
  // Return 1-based period index (1..n) or null if in a break / outside hours
}
```

---

### FEATURE 2 — Duplicate & Place

**File:** `lib/screens/week_screen.dart` (extend) + new `lib/state/placement_state.dart`

#### State object
```dart
// lib/state/placement_state.dart
class PlacementState {
  final bool active;
  final int? sourceDay;          // 1–6
  final int? sourcePeriodPos;    // position in day's period list (0-based)
  final Period? snapshot;        // full copy of the period being duplicated
  final Subject? subject;
  final List<({int day, int pos})> validTargets; // precomputed valid slots
  final List<({int day, int pos})> placed;        // undo stack

  const PlacementState({...});
  PlacementState copyWith({...});
  static const PlacementState inactive = PlacementState(active: false, ...);
}

final placementProvider = StateProvider<PlacementState>((ref) => PlacementState.inactive);
```

#### Valid target computation
```dart
List<({int day, int pos})> computeValidTargets(
  Timetable t,
  int sourceDay,
  int sourcePeriodPos,
  bool isLab,
) {
  final targets = <({int day, int pos})>[];
  for (var d = 1; d <= 6; d++) {
    final periods = t.periodsOn(d);
    final maxSlots = t.config.teaAfter > t.config.lunchAfter
        ? t.config.teaAfter  // use max configured
        : t.config.lunchAfter + 2; // approximate
    for (var pos = 0; pos < maxSlots; pos++) {
      // Skip source slot
      if (d == sourceDay && pos == sourcePeriodPos) continue;
      // Slot must be empty (pos >= periods.length OR periods[pos] is null)
      final isEmpty = pos >= periods.length;
      if (!isEmpty) continue;
      if (isLab) {
        // pos+1 must also be empty AND not cross a break
        final nextIsBreakBoundary = (pos + 1 == t.config.teaAfter) ||
            (pos + 1 == t.config.lunchAfter);
        final nextIsEmpty = (pos + 1) >= periods.length;
        if (!nextIsEmpty || nextIsBreakBoundary) continue;
      }
      targets.add((day: d, pos: pos));
    }
  }
  return targets;
}
```

#### UI changes in `week_screen.dart`
1. **Long press on `_ClassCell`** opens a `showModalBottomSheet` with 4 options:
   - 📋 Duplicate & Place
   - ↕️ Move (same as duplicate but removes source after placing)
   - ✏️ Edit → navigates to `EditDayScreen`
   - 🗑 Delete (with confirm dialog)

2. When "Duplicate & Place" is tapped:
   - Compute `validTargets`
   - Set `placementProvider` to active state
   - Sheet closes, grid stays on screen

3. **Placement mode visual layer:**
   - Valid target cells render as `_ValidTargetCell` (green dashed border, `+` icon, tappable)
   - Invalid/occupied cells dim to 35% opacity
   - Source card gets a pulsing glow (use `AnimationController` or simple `AnimatedContainer`)
   - A `Positioned` bottom chip: `"Tap a slot to place [Subject Name]  ✕"`
     - ✕ exits placement mode

4. **On tapping a valid target:**
   - Insert a copy of `snapshot` (new uuid) into `t.week[day]` at `pos`
   - For a lab, also fill `pos+1` (or handle via the existing lab model)
   - Show a quick `SnackBar`: "Physics added to Tuesday"
   - Placement mode stays active for more placements
   - Add action to `placed` stack for undo

5. **Room micro-prompt:**
   - After placement, show a small inline `AlertDialog`:
     "Same room (LH-101)?" [Keep] [Change]
   - "Change" opens a single `TextField` dialog for room number

6. **Undo:**
   - While placement mode is active, show an undo FAB
   - On press, remove the last placed slot

7. **Viewer mode guard:** wrap all long-press handlers with a check — if the timetable was joined via share link (read-only), long press does nothing.

---

### FEATURE 3 — Next-Day Timetable + Motivational Notes

**File:** `lib/screens/today_screen.dart` (extend) + `lib/logic/notes_engine.dart` (new)

#### Notes engine (`lib/logic/notes_engine.dart`)
```dart
/// Returns a contextual note based on the current timetable state.
/// Priority: attendance alert > lab reminder > streak > morning prep > generic
String pickNote({
  required DateTime now,
  required Timetable timetable,
  required Map<String, double> attendancePct, // subjectId → 0.0–1.0
}) {
  // 1. Low attendance alert (< 0.70)
  // 2. Lab today reminder ("You have Physics Lab today — bring your lab coat!")
  // 3. First class early warning (if tomorrow's first class is before 9am)
  // 4. Evening prep note (after last class — show tomorrow's schedule)
  // 5. Streak celebration
  // 6. Generic motivational pool — pick by day-of-week seed
}

const _genericNotes = [
  "Every class is one step closer to your degree 🎓",
  "Show up. That's already half the battle 💪",
  "Your future self will thank you for attending today 🙏",
  "One period at a time. You've got this ⚡",
  "Consistency beats intensity. Be consistent 📈",
];
```

#### `today_screen.dart` changes
1. **Before last class ends (normal mode):**
   - Show today's timeline as already implemented
   - Add a `NoteCard` widget at the top (below current class) showing `pickNote()`
   - `NoteCard`: rounded card, emoji + text, subtle background using primary color at 8% opacity

2. **After last class ends (next-day mode):**
   - Detect: `now` is after the last `TimelineEntry.endMin` for today
   - Replace the "today" content with a **Next Day Preview** section:
     ```
     🌙  Tomorrow — Tuesday, 10 Jun
     ─────────────────────────────
     P1  08:30  Physics         LH-101
     P2  09:25  Math Analysis   R-204
     ☕  Tea Break
     P3  10:40  Chemistry       LH-102
     ...
     ```
   - Show a `NoteCard` at the bottom: "Get some rest and be ready for tomorrow!"

3. **Weekend mode (Saturday after last class, or Sunday):**
   - Show Monday's schedule with title "Next Week — Monday, 14 Jun"
   - Note: "Enjoy your weekend! Monday's first class is at 8:30 🎒"

4. **No classes tomorrow / holiday:**
   - Show "No classes tomorrow 🎉" with a relaxed illustration (use `empty_state.dart`)

5. **NoteCard widget** (`lib/widgets/note_card.dart` — new file):
```dart
class NoteCard extends StatelessWidget {
  final String note;
  final IconData? icon;
  // Subtle top card, matches theme, auto-dark/light
}
```

---

### FEATURE 4 — Home-Screen Widget: Next-Day Preview + Notes

**File:** `lib/widgetkit/home_widget_service.dart` + `lib/widgetkit/home_widget_updater.dart`

The app already uses the `home_widget` package. Extend the data pushed to the widget:

Add these keys to the widget data bundle:
```dart
// Existing keys (keep)
'current_class', 'next_class', 'time_remaining', 'room'

// New keys to add
'is_next_day_mode'     // bool — true after last class ends
'next_day_label'       // "Tomorrow — Tue, 10 Jun"
'next_day_preview'     // "P1 Physics · P2 Math · ☕ · P3 Chem..."
'motivational_note'    // from notes_engine.dart
'attendance_warning'   // subject name if any subject < 70%, else ""
```

Update `home_widget_updater.dart` to call `pickNote()` and compute `isNextDayMode` before pushing data.

---

### FEATURE 5 — Settings Screen: Live Period Config

**File:** `lib/screens/settings_screen.dart`

Replace the existing settings with a properly grouped settings page:

#### Section 1 — Schedule Timing
- **Day Start Time** — `TimePickerDialog`, shows "8:30 AM"
- **Period Duration** — `Slider` (30–90 min, step 5), shows "50 minutes"
- **Lab Duration** — `Slider` (60–150 min, step 15), shows "120 minutes"

#### Section 2 — Tea Break
- **After Period** — `DropdownButton` (P1 through P6)
- **Duration** — `Slider` (5–30 min, step 5), shows "15 minutes"

#### Section 3 — Lunch Break
- **After Period** — `DropdownButton` (P1 through P6, must be > Tea Break)
- **Duration** — `Slider` (20–60 min, step 5), shows "45 minutes"

#### Section 4 — About This Timetable
- University, Branch, Semester, Section (already in `TimetableMeta` — expose as text fields)

**Validation:** Lunch break "After Period" must be strictly greater than Tea break "After Period". Show inline error if not.

**Live preview:** Add a compact `_PeriodPreviewStrip` widget below each section that shows the computed period times as a horizontal scroll: `P1 8:30 · P2 9:20 · ☕ · P3 9:35 · ...`. Updates instantly as sliders move.

---

### FEATURE 6 — Sharing Screen

**File:** `lib/screens/share_screen.dart`

The existing share codec (`lib/logic/share_codec.dart`) already encodes the timetable to a compact URL. Build the UI:

1. **Share card** — shows timetable meta (college, branch, sem, section)
2. **Large "Copy Link" button** — copies the encoded share URL to clipboard, shows "Copied!" confirmation
3. **QR code placeholder** — show a `Container` with a QR icon and "QR Code coming soon" (leave as placeholder, implement if `qr_flutter` is available in pubspec)
4. **"Join a Timetable" section** — `TextField` to paste a link + "Import" button → navigates to `ImportScreen`
5. **Role display** — show whether this device is the "Creator" (full edit) or "Viewer" (read-only). Creator badge: ✏️ Creator. Viewer badge: 👁 Viewing only.

---

## UI / DESIGN SYSTEM

Apply consistently across all screens:

### Theme (`lib/theme.dart`)
The existing `theme.dart` already has `SubjectColors`. Add:
```dart
// Consistent card decoration helper
BoxDecoration cardDecoration(ColorScheme scheme, {Color? accent}) => BoxDecoration(
  color: scheme.surfaceContainerLow,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
);

// Section header style
TextStyle sectionHeaderStyle(ColorScheme scheme) => TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.6,
  color: scheme.onSurfaceVariant,
);
```

### Design rules
- **Rounded corners:** 16px for cards, 12px for chips/badges, 8px for small tags
- **No horizontal scroll on the week grid on tablet** — adapt `_cellW` to screen width / column count
- **Dark theme:** already follows system. Ensure all new widgets use `Theme.of(context).colorScheme` — never hardcode colors
- **Typography:** use `Theme.of(context).textTheme.*` — never hardcode font sizes except for the day-date number (20px, w800)
- **Loading states:** use `CircularProgressIndicator.adaptive()` — never platform-specific spinners
- **Empty states:** reuse `lib/widgets/empty_state.dart`

---

## FILE CREATION CHECKLIST

Create or modify these files (in order):

1. `lib/state/placement_state.dart` — new
2. `lib/logic/notes_engine.dart` — new
3. `lib/widgets/note_card.dart` — new
4. `lib/screens/week_screen.dart` — extend (Duplicate & Place, NOW badge, past-day opacity)
5. `lib/screens/today_screen.dart` — extend (next-day mode, NoteCard)
6. `lib/screens/settings_screen.dart` — rebuild with live preview strip
7. `lib/screens/share_screen.dart` — rebuild UI
8. `lib/widgetkit/home_widget_updater.dart` — extend with new data keys
9. `lib/widgets/time_utils.dart` — add `mondayOf(DateTime)` helper if not already there

---

## VALIDATION RULES (enforce in UI)

| Rule | Where to enforce |
|------|-----------------|
| Lab cannot be placed at last period before Tea Break | `computeValidTargets()` + edit_day_screen save |
| Lab cannot be placed at last period before Lunch Break | same |
| Lunch break "after" > Tea break "after" | settings_screen validation |
| Period duration × total periods must finish before midnight | settings_screen validation |
| A day cannot have more periods than `max(teaAfter, lunchAfter) + 3` | edit_day_screen |

---

## WHAT NOT TO BUILD (out of scope for this session)

- Widget themes (Anime, Lo-Fi, Space, etc.) — planned but not in this sprint
- Real-time cloud sync (Supabase/Firebase) — share codec is URL-based for now
- Android Glance / iOS WidgetKit native code — the `home_widget` package handles the bridge
- Attendance tracking system — future feature

---

## OUTPUT FORMAT

For each file you create or modify:
1. Show the full file (not a diff)
2. Add a 2-line comment at the top: what this file does and what changed
3. After all files, show a brief summary of what was built

Start with `lib/state/placement_state.dart`, then proceed in checklist order.
