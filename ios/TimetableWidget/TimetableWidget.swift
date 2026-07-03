import WidgetKit
import SwiftUI

// Must match HomeWidgetService.iOSAppGroupId in the Flutter app.
private let appGroupId = "group.com.dhruvash148.timetable"

/// One snapshot of the rendered widget images shared from the Flutter app via
/// the App Group's UserDefaults (written by `home_widget`'s renderFlutterWidget).
struct TimetableEntry: TimelineEntry {
    let date: Date
    let smallPath: String?
    let mediumPath: String?
    let largePath: String?
    let bgHex: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TimetableEntry {
        TimetableEntry(date: Date(), smallPath: nil, mediumPath: nil, largePath: nil, bgHex: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimetableEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimetableEntry>) -> Void) {
        let entry = readEntry()
        // Home-screen widgets can't tick every minute; refresh ~every 15 min.
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())
            ?? Date().addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func readEntry() -> TimetableEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return TimetableEntry(
            date: Date(),
            smallPath: defaults?.string(forKey: "tt_small"),
            mediumPath: defaults?.string(forKey: "tt_medium"),
            largePath: defaults?.string(forKey: "tt_large"),
            bgHex: defaults?.string(forKey: "widget_container_bg")
        )
    }
}

struct TimetableWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    private var path: String? {
        switch family {
        case .systemSmall: return entry.smallPath
        case .systemMedium: return entry.mediumPath
        default: return entry.largePath
        }
    }

    // Edge colour behind the card (pushed from Flutter per Light/Dark); shown
    // only in the placeholder / any AA seam. Falls back to the dark card colour.
    private var bgColor: Color {
        Color(hex: entry.bgHex) ?? Color(red: 0.086, green: 0.106, blue: 0.133)
    }

    // The rendered card, scaled to fill the whole widget (the PNG already IS the
    // full themed design).
    @ViewBuilder private var fill: some View {
        if let path = path, let image = UIImage(contentsOfFile: path) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            bgColor.overlay(
                VStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text("Open Timetable").font(.caption)
                }
                .foregroundColor(.white)
            )
        }
    }

    var body: some View {
        // Put the card in the widget's CONTAINER BACKGROUND so it fills the whole
        // widget edge-to-edge. The foreground content area is inset by the system
        // content margins (iOS 17+); the container background is not — that inset
        // was the "frame" showing around the card.
        Color.clear.widgetBackgroundCompat(fill)
    }
}

extension Color {
    /// Parses `#AARRGGBB` / `#RRGGBB` (alpha ignored) into a `Color`.
    init?(hex: String?) {
        guard var s = hex else { return nil }
        if s.hasPrefix("#") { s.removeFirst() }
        if s.count == 8 { s = String(s.suffix(6)) } // drop leading alpha
        guard s.count == 6, let v = Int(s, radix: 16) else { return nil }
        self.init(
            red: Double((v >> 16) & 0xFF) / 255.0,
            green: Double((v >> 8) & 0xFF) / 255.0,
            blue: Double(v & 0xFF) / 255.0)
    }
}

extension View {
    /// `containerBackground` is iOS 17+. Fall back to a plain background on
    /// iOS 14–16 so the widget still builds and renders.
    @ViewBuilder
    func widgetBackgroundCompat<B: View>(_ background: B) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) { background }
        } else {
            self.background(background)
        }
    }
}

@main
struct TimetableWidget: Widget {
    let kind: String = "TimetableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimetableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Timetable")
        .description("Your class day at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
