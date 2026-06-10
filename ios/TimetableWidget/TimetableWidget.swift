import WidgetKit
import SwiftUI

// Must match HomeWidgetService.iOSAppGroupId in the Flutter app.
private let appGroupId = "group.com.example.timetable"

/// One snapshot of the rendered widget images shared from the Flutter app via
/// the App Group's UserDefaults (written by `home_widget`'s renderFlutterWidget).
struct TimetableEntry: TimelineEntry {
    let date: Date
    let smallPath: String?
    let mediumPath: String?
    let largePath: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TimetableEntry {
        TimetableEntry(date: Date(), smallPath: nil, mediumPath: nil, largePath: nil)
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
            largePath: defaults?.string(forKey: "tt_large")
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

    private var background: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.33, green: 0.67, blue: 0.93),
                     Color(red: 0.18, green: 0.47, blue: 0.80)],
            startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            if let path = path, let image = UIImage(contentsOfFile: path) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text("Open Timetable").font(.caption)
                }
                .foregroundColor(.white)
            }
        }
        .widgetBackgroundCompat(background)
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
