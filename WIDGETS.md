# Home-screen widgets

The app renders the three Weather-style layouts (small / medium / large) to
images and shares them with native home-screen widgets via the
[`home_widget`](https://pub.dev/packages/home_widget) package. The images are
refreshed when the app is opened, when it's resumed, and every minute while it's
in the foreground. Home-screen widgets are then refreshed by the OS on its own
cadence.

> **Update frequency:** the OS throttles home-screen widgets — Android refreshes
> roughly every 30 min (+ on the app opening), iOS roughly every 15 min. So the
> live completion % on the home screen updates periodically, not every minute.
> The in-app **Widgets** tab stays live every minute.

## Android — works out of the box

Already wired into the APK. To add it:

1. Long-press an empty area of your home screen → **Widgets**.
2. Find **timetable** → drag the **Timetable** widget onto your home screen.
3. **Resize it** — a 2×2 size shows the small layout, a wide 4×2 shows the
   medium layout, and a tall 4×4 shows the full-day large layout.

Open the app once first so the widget has fresh data to show.

Files: `android/app/src/main/kotlin/com/example/timetable/TimetableWidgetProvider.kt`,
`res/layout/timetable_widget.xml`, `res/xml/timetable_widget_info.xml`, and the
`<receiver>` in `AndroidManifest.xml`.

## iOS — add the WidgetKit target in Xcode

An iOS widget lives in a separate app-extension **target**, which must be added
through Xcode (it can't be sideloaded like an APK). The Swift code is ready in
[`ios/TimetableWidget/`](ios/TimetableWidget/).

1. `open ios/Runner.xcworkspace`
2. **File → New → Target… → Widget Extension**. Name it **TimetableWidget**.
   Uncheck "Include Live Activity" / "Include Configuration App Intent".
3. When prompted to activate the scheme, click **Activate**.
4. Replace the auto-generated `TimetableWidget.swift` with the one in
   `ios/TimetableWidget/TimetableWidget.swift` (provided here).
5. Add the **App Group** to **both** targets (Runner *and* TimetableWidget):
   select the target → **Signing & Capabilities → + Capability → App Groups**,
   then add `group.com.example.timetable`.
   - This must match `HomeWidgetService.iOSAppGroupId` in
     [`lib/widgetkit/home_widget_service.dart`](lib/widgetkit/home_widget_service.dart)
     and `appGroupId` in the Swift file.
6. Set the widget target's **Minimum Deployments** to **iOS 17** (for
   `containerBackground`).
7. Build & run the **Runner** scheme on a simulator/device, open the app once,
   then long-press the home screen → **+** → search **Timetable** → add it.

## Changing the bundle id / app group

If you change the app's bundle id from `com.example.timetable`:

- Android: rename the package and update `HomeWidgetService.androidProvider`.
- iOS: pick a new App Group id and update it in **both** the Swift file and
  `HomeWidgetService.iOSAppGroupId`.
