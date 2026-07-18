import Foundation

func relativeReset(from date: Date, now: Date) -> String {
    let secs = Int(date.timeIntervalSince(now))
    if secs <= 0 { return "resetting…" }
    let mins = secs / 60
    let h = mins / 60
    let m = mins % 60
    if h > 0 { return "resets in \(h)h \(m)m" }
    return "resets in \(m)m"
}

func absoluteReset(from date: Date, calendar: Calendar = .current) -> String {
    let f = DateFormatter()
    f.calendar = calendar
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = calendar.timeZone
    f.dateFormat = "EEE h:mm a"
    return "resets \(f.string(from: date))"
}
