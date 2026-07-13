import WidgetKit
import SwiftUI

// Must match HomeWidgetService.iOSAppGroupId in the Flutter app.
private let appGroupId = "group.com.dhruvash148.timetable"

// MARK: - Model

struct Slot {
    let start: Int      // minutes from midnight
    let end: Int
    let title: String
    let color: Int      // ARGB int of the subject colour
    let kind: String    // regular | lab | tea | lunch
    let room: String
    let teacher: String
    var isBreak: Bool { kind == "tea" || kind == "lunch" }
    var isLab: Bool { kind == "lab" }
    var dur: Int { max(1, end - start) }
}

struct WidgetData {
    let slotsByDay: [Int: [Slot]]   // ISO weekday 1(Mon)…7(Sun)
    let bgTop: Color
    let bgBottom: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let hairline: Color
    let labelCurrent: String
    let labelUpNext: String
    let labelBreak: String
    let hasData: Bool

    static func load() -> WidgetData {
        let d = UserDefaults(suiteName: appGroupId)
        var byDay: [Int: [Slot]] = [:]
        var has = false
        if let js = d?.string(forKey: "tt_timelines"),
           let data = js.data(using: .utf8),
           let obj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
            for (k, v) in obj {
                guard let day = Int(k), let arr = v as? [[String: Any]] else { continue }
                let slots = arr.map { m in
                    Slot(start: (m["s"] as? Int) ?? 0,
                         end: (m["e"] as? Int) ?? 0,
                         title: (m["t"] as? String) ?? "",
                         color: (m["c"] as? Int) ?? 0xFF5965C8,
                         kind: (m["k"] as? String) ?? "regular",
                         room: (m["room"] as? String) ?? "",
                         teacher: (m["teacher"] as? String) ?? "")
                }.sorted { $0.start < $1.start }
                if !slots.isEmpty { has = true }
                byDay[day] = slots
            }
        }
        func col(_ key: String, _ fallback: Color) -> Color {
            Color(hex: d?.string(forKey: key)) ?? fallback
        }
        return WidgetData(
            slotsByDay: byDay,
            bgTop: col("theme_bg_top", Color(rgb: 0x323B4A)),
            bgBottom: col("theme_bg_bottom", Color(rgb: 0x161B22)),
            textPrimary: col("theme_text_primary", .white),
            textSecondary: col("theme_text_secondary", Color.white.opacity(0.72)),
            accent: col("theme_accent", Color(rgb: 0x5965C8)),
            hairline: col("theme_hairline", Color.white.opacity(0.14)),
            labelCurrent: d?.string(forKey: "theme_label_current") ?? "IN PROGRESS",
            labelUpNext: d?.string(forKey: "theme_label_upnext") ?? "UP NEXT",
            labelBreak: d?.string(forKey: "theme_label_break") ?? "ON BREAK",
            hasData: has)
    }
}

// MARK: - Status computed for a given instant

struct Status {
    enum Mode { case empty, beforeDay, inClass, onBreak, dayOver }
    let mode: Mode
    let current: Slot?
    let progress: Double
    let upNext: [Slot]
    let weekday: Int
    let weekdayShort: String
    let weekdayFull: String
    let dateLabel: String
    let nextDaySlots: [Slot]
    let nextDayLabel: String
}

private let shortDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
private let fullDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

private func isoWeekday(_ date: Date) -> Int {
    let wd = Calendar.current.component(.weekday, from: date) // 1=Sun…7=Sat
    return wd == 1 ? 7 : wd - 1                                // 1=Mon…7=Sun
}

private func minutesOfDay(_ date: Date) -> Int {
    let c = Calendar.current.dateComponents([.hour, .minute], from: date)
    return (c.hour ?? 0) * 60 + (c.minute ?? 0)
}

/// Walks forward from `wd` (ISO weekday, 1=Mon…7=Sun) to find the next day that
/// has any classes, returning its slots and a display label ("Tomorrow" for the
/// immediate next day, else the full weekday name).
private func nextDayWithClasses(_ data: WidgetData, from wd: Int) -> (slots: [Slot], label: String) {
    for off in 1...7 {
        let cand = ((wd - 1 + off) % 7) + 1
        if let slots = data.slotsByDay[cand], !slots.isEmpty {
            let label = off == 1 ? "Tomorrow" : fullDays[(cand - 1) % 7]
            return (slots, label)
        }
    }
    return ([], "")
}

private func hm(_ minutes: Int) -> String {
    var h = minutes / 60
    let m = minutes % 60
    let ampm = h < 12 ? "AM" : "PM"
    h = h % 12; if h == 0 { h = 12 }
    return String(format: "%d:%02d %@", h, m, ampm)
}

private func computeStatus(_ data: WidgetData, _ date: Date) -> Status {
    let wd = isoWeekday(date)
    let slots = data.slotsByDay[wd] ?? []
    let now = minutesOfDay(date)
    let short = shortDays[(wd - 1) % 7]
    let full = fullDays[(wd - 1) % 7]
    let c = Calendar.current.dateComponents([.day, .month], from: date)
    let dateLabel = "\(c.day ?? 1) \(months[((c.month ?? 1) - 1) % 12])"

    let next = nextDayWithClasses(data, from: wd)
    func result(_ mode: Status.Mode, _ cur: Slot?, _ prog: Double) -> Status {
        let up = slots.filter { $0.start >= now && !$0.isBreak }
        return Status(mode: mode, current: cur, progress: prog, upNext: up,
                      weekday: wd, weekdayShort: short, weekdayFull: full, dateLabel: dateLabel,
                      nextDaySlots: next.slots, nextDayLabel: next.label)
    }
    if slots.isEmpty { return result(.empty, nil, 0) }
    if now < slots.first!.start { return result(.beforeDay, nil, 0) }
    if now >= slots.last!.end { return result(.dayOver, nil, 1) }
    if let cur = slots.first(where: { now >= $0.start && now < $0.end }) {
        let p = Double(now - cur.start) / Double(cur.dur)
        return result(cur.isBreak ? .onBreak : .inClass, cur, p)
    }
    return result(.beforeDay, nil, 0) // in a gap between classes → treat as up-next
}

// MARK: - Provider (timeline advances automatically through the day)

struct Entry: TimelineEntry { let date: Date; let data: WidgetData }

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: Date(), data: WidgetData.load()) }
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: Date(), data: WidgetData.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let data = WidgetData.load()
        let cal = Calendar.current
        let now = Date()
        let startOfDay = cal.startOfDay(for: now)
        func at(_ minutes: Int) -> Date { startOfDay.addingTimeInterval(TimeInterval(minutes * 60)) }

        var marks: [Date] = [now]
        let slots = data.slotsByDay[isoWeekday(now)] ?? []
        for s in slots {
            marks.append(at(s.start))
            marks.append(at(s.end))
            // intra-class ticks (~10 min) so the progress bar advances during class
            var m = s.start + 10
            while m < s.end { marks.append(at(m)); m += 10 }
        }
        // future, unique, sorted, capped (WidgetKit budget)
        var seen = Set<Int>(); var future: [Date] = []
        for dte in marks.sorted() where dte >= now.addingTimeInterval(-60) {
            let key = Int(dte.timeIntervalSince1970 / 60)
            if !seen.contains(key) { seen.insert(key); future.append(dte) }
        }
        if future.isEmpty { future = [now] }
        let entries = Array(future.prefix(70)).map { Entry(date: $0, data: data) }

        // Reload at the start of tomorrow to pick up the next day's schedule.
        let reload = cal.date(byAdding: .day, value: 1, to: startOfDay) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: entries, policy: .after(reload)))
    }
}

// MARK: - Views

struct TimetableWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Entry

    var body: some View {
        let s = computeStatus(entry.data, entry.date)
        Group {
            if !entry.data.hasData {
                placeholder
            } else {
                switch family {
                case .systemSmall: SmallView(s: s, data: entry.data)
                case .systemLarge: LargeView(s: s, data: entry.data)
                default: MediumView(s: s, data: entry.data)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetBackgroundCompat(
            LinearGradient(colors: [entry.data.bgTop, entry.data.bgBottom],
                           startPoint: .top, endPoint: .bottom))
    }

    private var placeholder: some View {
        VStack(spacing: 4) {
            Image(systemName: "calendar")
            Text("Open Timetable").font(.caption)
        }.foregroundColor(entry.data.textPrimary)
    }
}

// Shared bits ---------------------------------------------------------------

private func slotColor(_ s: Slot) -> Color { Color(argb: s.color) }

private func progressColor(_ t: Double) -> Color {
    let x = max(0, min(1, t))
    if x < 0.5 { return Color(red: 0.90, green: 0.32 + 0.53 * (x / 0.5), blue: 0.28) }
    let y = (x - 0.5) / 0.5
    return Color(red: 0.90 - 0.55 * y, green: 0.72, blue: 0.34)
}

private struct HeaderRow: View {
    let left: String, right: String, data: WidgetData
    var body: some View {
        HStack {
            Text(left).font(.system(size: 12, weight: .bold)).tracking(1.1)
                .foregroundColor(data.textSecondary)
            Spacer()
            Text(right).font(.system(size: 12, weight: .medium))
                .foregroundColor(data.textSecondary)
        }
    }
}

private struct ProgressBar: View {
    let p: Double
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.18))
                Capsule().fill(progressColor(p)).frame(width: max(6, g.size.width * p))
            }
        }.frame(height: 7)
    }
}

// Small ---------------------------------------------------------------------

private struct SmallView: View {
    let s: Status; let data: WidgetData
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderRow(left: s.weekdayShort, right: s.dateLabel, data: data)
            Spacer(minLength: 6)
            switch s.mode {
            case .inClass, .onBreak:
                let cur = s.current!
                Text(s.mode == .onBreak ? (cur.kind == "lunch" ? "Lunch break" : "Tea break") : cur.title)
                    .font(.system(size: 15, weight: .semibold)).lineLimit(2)
                    .foregroundColor(data.textPrimary)
                Text("\(Int(s.progress * 100))% · ends \(hm(cur.end))")
                    .font(.system(size: 11)).foregroundColor(data.textSecondary)
                    .padding(.top, 2)
                ProgressBar(p: s.progress).padding(.top, 6)
            case .beforeDay:
                Text("Day ahead").font(.system(size: 15, weight: .semibold)).foregroundColor(data.textPrimary)
                if let n = s.upNext.first {
                    Text("Starts \(hm(n.start))").font(.system(size: 11)).foregroundColor(data.textSecondary)
                }
            case .dayOver:
                Text(s.nextDayLabel.isEmpty ? "All done" : s.nextDayLabel)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(data.textPrimary)
                if let n = s.nextDaySlots.first {
                    Text("Starts \(hm(n.start))").font(.system(size: 11)).foregroundColor(data.textSecondary)
                } else {
                    Text("See you tomorrow").font(.system(size: 11)).foregroundColor(data.textSecondary)
                }
            case .empty:
                Text(s.nextDayLabel.isEmpty ? "No classes" : s.nextDayLabel)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(data.textPrimary)
                if let n = s.nextDaySlots.first {
                    Text("Starts \(hm(n.start))").font(.system(size: 11)).foregroundColor(data.textSecondary)
                } else {
                    Text("Enjoy the day").font(.system(size: 11)).foregroundColor(data.textSecondary)
                }
            }
            Spacer(minLength: 6)
            if let up = (s.mode == .dayOver || s.mode == .empty) ? s.nextDaySlots.first : s.upNext.first {
                HStack(spacing: 6) {
                    Circle().fill(slotColor(up)).frame(width: 7, height: 7)
                    Text(hm(up.start)).font(.system(size: 10, weight: .semibold)).foregroundColor(data.textSecondary)
                    Text(up.title).font(.system(size: 10)).lineLimit(1).foregroundColor(data.textPrimary)
                }
            }
        }
    }
}

// Medium --------------------------------------------------------------------

private struct MediumView: View {
    let s: Status; let data: WidgetData
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HeaderRow(left: s.weekdayShort, right: s.dateLabel, data: data)
                Spacer(minLength: 2)
                switch s.mode {
                case .inClass, .onBreak:
                    let cur = s.current!
                    Text(s.mode == .onBreak ? data.labelBreak : data.labelCurrent)
                        .font(.system(size: 10, weight: .bold)).tracking(1).foregroundColor(data.accent)
                    Text(s.mode == .onBreak ? (cur.kind == "lunch" ? "Lunch break" : "Tea break") : cur.title)
                        .font(.system(size: 17, weight: .bold)).lineLimit(2).foregroundColor(data.textPrimary)
                    if !cur.room.isEmpty && !cur.isBreak {
                        Text(cur.room).font(.system(size: 11)).foregroundColor(data.textSecondary)
                    }
                    ProgressBar(p: s.progress).padding(.top, 4)
                    Text("\(Int(s.progress * 100))% · ends \(hm(cur.end))")
                        .font(.system(size: 10)).foregroundColor(data.textSecondary)
                default:
                    Text(title(s)).font(.system(size: 18, weight: .bold)).foregroundColor(data.textPrimary)
                    Text(subtitle(s)).font(.system(size: 11)).foregroundColor(data.textSecondary)
                }
                Spacer(minLength: 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle().fill(data.hairline).frame(width: 1)

            VStack(alignment: .leading, spacing: 6) {
                let showingNextDay = s.mode == .dayOver || s.mode == .empty
                let list = showingNextDay ? s.nextDaySlots : s.upNext
                Text(showingNextDay && !s.nextDayLabel.isEmpty ? s.nextDayLabel.uppercased() : data.labelUpNext)
                    .font(.system(size: 10, weight: .bold)).tracking(1)
                    .foregroundColor(data.textSecondary)
                if list.isEmpty {
                    Text("No more classes").font(.system(size: 12)).foregroundColor(data.textSecondary)
                } else {
                    ForEach(Array(list.prefix(3).enumerated()), id: \.offset) { _, n in
                        HStack(spacing: 7) {
                            Circle().fill(slotColor(n)).frame(width: 8, height: 8)
                            Text(hm(n.start)).font(.system(size: 11, weight: .semibold))
                                .foregroundColor(data.textSecondary).frame(width: 58, alignment: .leading)
                            Text(n.title).font(.system(size: 12)).lineLimit(1).foregroundColor(data.textPrimary)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    private func title(_ s: Status) -> String {
        switch s.mode {
        case .beforeDay: return "Day ahead"
        case .dayOver: return s.nextDayLabel.isEmpty ? "All done" : s.nextDayLabel
        case .empty: return s.nextDayLabel.isEmpty ? "No classes" : s.nextDayLabel
        default: return "No classes" } }
    private func subtitle(_ s: Status) -> String {
        switch s.mode {
        case .beforeDay: return s.upNext.first.map { "Starts \(hm($0.start))" } ?? ""
        case .dayOver: return s.nextDaySlots.first.map { "Starts \(hm($0.start))" } ?? "See you tomorrow"
        case .empty: return s.nextDaySlots.first.map { "Starts \(hm($0.start))" } ?? "Enjoy the day"
        default: return "Enjoy the day" } }
}

// Large ---------------------------------------------------------------------

private struct LargeView: View {
    let s: Status; let data: WidgetData
    var body: some View {
        let showingNextDay = s.mode == .dayOver || s.mode == .empty
        let slots = showingNextDay ? s.nextDaySlots : (data.slotsByDay[s.weekday] ?? [])
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(s.weekdayFull).font(.system(size: 20, weight: .bold)).foregroundColor(data.textPrimary)
                    Text(s.dateLabel).font(.system(size: 12)).foregroundColor(data.textSecondary)
                }
                Spacer()
                Text(statusLine).font(.system(size: 12, weight: .semibold))
                    .foregroundColor(data.textSecondary).multilineTextAlignment(.trailing)
            }
            Rectangle().fill(data.hairline).frame(height: 1)
            if showingNextDay && !s.nextDayLabel.isEmpty {
                Text(s.nextDayLabel.uppercased()).font(.system(size: 11, weight: .bold)).tracking(1)
                    .foregroundColor(data.textSecondary)
            }
            if slots.isEmpty {
                Spacer(); Text(showingNextDay ? "No classes" : "No classes today")
                    .font(.system(size: 14)).foregroundColor(data.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center); Spacer()
            } else {
                ForEach(Array(slots.prefix(8).enumerated()), id: \.offset) { _, slot in
                    row(slot)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var statusLine: String {
        switch s.mode {
        case .inClass: return "In progress"
        case .onBreak: return "On break"
        case .dayOver: return "All classes done"
        case .beforeDay: return s.upNext.first.map { "Starts \(hm($0.start))" } ?? ""
        case .empty: return "Enjoy the day" }
    }

    private func row(_ slot: Slot) -> some View {
        let isCurrent = s.current.map { $0.start == slot.start && $0.end == slot.end } ?? false
        return HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(slot.isBreak ? data.textSecondary.opacity(0.5) : slotColor(slot))
                .frame(width: 4, height: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(hm(slot.start)).font(.system(size: 12, weight: .semibold)).foregroundColor(data.textPrimary)
                Text(hm(slot.end)).font(.system(size: 10)).foregroundColor(data.textSecondary)
            }.frame(width: 62, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    if slot.isBreak {
                        Image(systemName: slot.kind == "lunch" ? "fork.knife" : "cup.and.saucer.fill")
                            .font(.system(size: 10)).foregroundColor(data.textSecondary)
                    }
                    Text(slot.isBreak ? (slot.kind == "lunch" ? "Lunch Break" : "Tea Break") : slot.title)
                        .font(.system(size: 13, weight: .semibold)).lineLimit(1).foregroundColor(data.textPrimary)
                    if slot.isLab {
                        Text("LAB").font(.system(size: 8, weight: .bold)).padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Capsule().fill(data.textSecondary.opacity(0.25))).foregroundColor(data.textPrimary)
                    }
                }
                if !slot.isBreak && (!slot.teacher.isEmpty || !slot.room.isEmpty) {
                    Text([slot.teacher, slot.room].filter { !$0.isEmpty }.joined(separator: " · "))
                        .font(.system(size: 10)).lineLimit(1).foregroundColor(data.textSecondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 3).padding(.horizontal, 6)
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(isCurrent ? data.accent.opacity(0.22) : Color.clear))
    }
}

// MARK: - Compat + colour helpers

extension View {
    @ViewBuilder
    func widgetBackgroundCompat<B: View>(_ background: B) -> some View {
        if #available(iOS 17.0, *) { self.containerBackground(for: .widget) { background } }
        else { self.padding(14).frame(maxWidth: .infinity, maxHeight: .infinity).background(background) }
    }
}

extension Color {
    init?(hex: String?) {
        guard var s = hex else { return nil }
        if s.hasPrefix("#") { s.removeFirst() }
        if s.count == 8 { s = String(s.suffix(6)) }
        guard s.count == 6, let v = Int(s, radix: 16) else { return nil }
        self.init(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255,
                  blue: Double(v & 0xFF) / 255)
    }
    init(rgb: Int) {
        self.init(red: Double((rgb >> 16) & 0xFF) / 255, green: Double((rgb >> 8) & 0xFF) / 255,
                  blue: Double(rgb & 0xFF) / 255)
    }
    init(argb: Int) { self.init(rgb: argb & 0xFFFFFF) }
}

// MARK: - Widget

@main
struct TimetableWidget: Widget {
    let kind: String = "TimetableWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimetableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Timetable")
        .description("Your class day at a glance — updates through the day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
