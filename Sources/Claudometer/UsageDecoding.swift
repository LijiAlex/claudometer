import Foundation

func makeUsageDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .custom { d in
        let raw = try d.singleValueContainer().decode(String.self)
        if let date = isoParse(raw) { return date }
        throw DecodingError.dataCorrupted(.init(codingPath: d.codingPath,
            debugDescription: "Unrecognized date: \(raw)"))
    }
    return decoder
}

// The API returns microsecond precision with a numeric offset, e.g.
// "2026-07-18T01:50:00.167209+00:00". ISO8601DateFormatter is unreliable
// with 6 fractional digits, so try fractional then whole-second formats.
private let isoFractional: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()
private let isoWhole: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
}()

func isoParse(_ s: String) -> Date? {
    // ISO8601DateFormatter with fractional seconds accepts only up to
    // millisecond digits; truncate any longer fraction before parsing.
    let normalized = truncateFraction(s)
    return isoFractional.date(from: normalized) ?? isoWhole.date(from: s)
}

private func truncateFraction(_ s: String) -> String {
    guard let dot = s.firstIndex(of: ".") else { return s }
    var i = s.index(after: dot)
    var digits = 0
    while i < s.endIndex, s[i].isNumber {
        if digits == 3 { break }
        i = s.index(after: i); digits += 1
    }
    // drop remaining fraction digits, keep the timezone tail
    var tail = i
    while tail < s.endIndex, s[tail].isNumber { tail = s.index(after: tail) }
    return String(s[s.startIndex..<i]) + String(s[tail...])
}
