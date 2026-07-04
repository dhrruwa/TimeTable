# Timetable / ClassSync — Store Submission Guide

Everything you paste/upload for **Google Play** and the **App Store**. The app
code is done, signed, and pushed to `main`.

## App identity (both stores)
| Field | Value |
|---|---|
| Package / Bundle ID | `com.dhruvash148.timetable` |
| Version | `1.0.0 (1)` |
| Privacy Policy URL | https://classsync.dhrruwa.com/privacy |
| Terms of Use URL | https://classsync.dhrruwa.com/terms |
| Support email | support@dhrruwa.com |
| Category | Education |
| Content | Everyone / 4+ |
| Ads | No |
| In-app purchases | No |

## Assets in this folder (`play/`)
- `ClassSync-release.aab` — **signed app bundle** → upload to Play.
- `feature_graphic.png` — **1024×500** Play feature graphic.
- `icon_512.png` — **512×512** hi-res icon (Play).
- `screenshots/` — put 2–8 phone screenshots here (see checklist).

---

## Listing copy (paste as-is)

**App name** (Play ≤30 chars): `ClassSync: Class Timetable`
(iOS name ≤30 chars): `ClassSync Timetable`

**Short description** (Play ≤80 chars):
`Your whole class on one live timetable — widgets, AI import, and QR sharing.`

**Subtitle** (iOS ≤30 chars): `One class, one timetable`

**Full description** (Play ≤4000 chars / App Store description):
```
ClassSync is the simplest way for a college class to share one timetable.

One student builds the timetable — everyone else finds it and joins with a
single tap. No more screenshots in the group chat.

• ONE CLASS, ONE TIMETABLE
Search your university, branch, semester and section and instantly join your
class's timetable if a classmate already made it.

• LIVE HOME-SCREEN WIDGET
A beautiful widget shows your current class, a live progress ring, and what's
up next — updating through the day. Small, medium and large sizes.

• AI IMPORT
Have a timetable as a photo or PDF? Import it automatically — ClassSync reads
it and builds your schedule for you.

• SHARE BY QR OR LINK
Share your whole timetable with a QR code or a link. It works offline — the
link itself carries the timetable.

• PER-DAY SCHEDULES & BREAKS
Set class timings, labs, tea and lunch breaks — even when they differ by day.

• PRIVATE BY DESIGN
No login. No ads. No tracking. Your data stays on your device; only the
timetables you choose to publish are shared with your class.

Built for students. Never miss a class again.
```

**Keywords** (iOS, ≤100 chars):
`timetable,class,schedule,college,university,student,attendance,widget,study,routine`

---

## GOOGLE PLAY — step by step
1. **play.google.com/console** → **Create app** (name, language, App/Free).
2. Accept declarations → complete the **Dashboard setup** tasks:
   - **App access** → "All functionality available without special access".
   - **Ads** → No.
   - **Content rating** → run questionnaire (Education; no violence/etc → likely **Everyone**).
   - **Target audience** → 13+ (or 18+ to avoid families policy overhead).
   - **Data safety** → see table below.
   - **Government apps / Financial** → No.
   - **Privacy Policy** → paste the URL above.
3. **Store listing**: app name, short + full description (above), upload
   `icon_512.png`, `feature_graphic.png`, and **≥2 phone screenshots**.
4. **Production → Create release**:
   - Opt into **Play App Signing** (upload key = your `upload-keystore.jks`).
   - Upload `ClassSync-release.aab`.
   - Release notes: `First release of ClassSync.`
5. Set **countries** (all / India), **Save → Review → Rollout to Production**.
   First review typically takes a few hours–2 days.

### Play Data Safety answers
| Question | Answer |
|---|---|
| Does your app collect/share user data? | **Yes** |
| Encrypted in transit? | **Yes** (HTTPS) |
| Users can request deletion? | **Yes** — via support email (no account) |
| **Device or other IDs** | Collected (a random per-device ID, to attribute published timetables). Purpose: **App functionality**. Not linked to identity. Not for tracking. |
| **Personal info → Name** | Collected *optionally* (creator name on a published timetable). Purpose: App functionality. |
| **Photos** (AI import) | Collected & processed to build your timetable; **not stored/retained**. Purpose: App functionality. |
| App activity / location / contacts / financial | **None** |
| Third-party analytics / ads SDKs | **None** |

---

## APP STORE — step by step
> Requires a **Mac + Xcode** (the archive/upload can't be done from CLI alone).
1. **developer.apple.com** → Certificates, IDs & Profiles → confirm the App ID
   `com.dhruvash148.timetable` exists and the **App Group**
   `group.com.dhruvash148.timetable` is enabled on it (for the widget).
2. **appstoreconnect.apple.com** → **My Apps → +** → New App:
   - Platform iOS, name `ClassSync Timetable`, bundle ID above, SKU any.
3. In Xcode: open `ios/Runner.xcworkspace` → set version `1.0`, build `1` →
   **Product → Archive** → **Distribute App → App Store Connect → Upload**.
   (Or use Transporter with an exported `.ipa`.)
4. In App Store Connect, on the version:
   - **Screenshots** (6.7" iPhone required; add 6.5"/iPad if supporting).
   - **Description / keywords / subtitle** (above), support + privacy URLs.
   - **App Privacy** → see nutrition label below.
   - **Age rating** questionnaire → 4+.
5. **Add for Review → Submit**. (TestFlight first is recommended.)

### App Store — App Privacy ("nutrition label")
Data **Not Linked to You**, used only for **App Functionality**, **not** for tracking:
- **Identifiers** — a device-generated ID (attributes published timetables).
- **User Content** — timetables you publish; optional creator name.
- **Photos** — only if you use AI import (image sent for processing, not retained).

Camera usage (QR scanning) is on-device; the purpose string is already in
`Info.plist`. Encryption: `ITSAppUsesNonExemptEncryption = false` (standard HTTPS).

### Guideline 1.2 (user-generated content) — already covered ✅
- In-app **report** and **block & hide** for community timetables.
- **EULA/Terms** with a zero-tolerance objectionable-content clause + 24h
  moderation commitment (link above), shown in-app.

---

## Screenshots to capture (2–8, phone)
Best set: **Today** (with a class in progress), **Week** grid, **Find your class**
(community search result), **Share & QR**, **Schedule settings**, and the
**home-screen widget**. Portrait, device default resolution.
