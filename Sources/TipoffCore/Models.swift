import Foundation

public enum ScheduleGuide: String, Codable, CaseIterable, Sendable {
    case nba, nfl
    public var title: String { self == .nba ? "NBA" : "NFL" }
    public var symbol: String { self == .nba ? "basketball.fill" : "american.football.fill" }
}

public struct Broadcast: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var name: String
    public var category: String
    public var id: String { category + ":" + name.lowercased() }
    public init(name: String, category: String) { self.name = name; self.category = category }
}

public struct Game: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var away: String
    public var home: String
    public var awayCode: String
    public var homeCode: String
    public var start: Date?
    public var scheduleDay: String
    public var notice: String?
    public var broadcasts: [Broadcast]
    public var altitude: AltitudeDetails?
    public init(id: String, away: String, home: String, awayCode: String, homeCode: String,
                start: Date?, scheduleDay: String, notice: String? = nil, broadcasts: [Broadcast]) {
        self.id = id; self.away = away; self.home = home; self.awayCode = awayCode; self.homeCode = homeCode
        self.start = start; self.scheduleDay = scheduleDay; self.notice = notice; self.broadcasts = broadcasts
    }
    public var isBroncos: Bool { id.hasPrefix("nfl-") && (awayCode == "DEN" || homeCode == "DEN") }
    public var isNuggets: Bool { !id.hasPrefix("nfl-") && (awayCode == "DEN" || homeCode == "DEN") }
    public func falls(on date: Date, calendar: Calendar) -> Bool {
        if let start { return calendar.isDate(start, inSameDayAs: date) }
        return scheduleDay == Dates.key(date, timeZone: calendar.timeZone)
    }
    public func timeLabel(timeZone: TimeZone = .autoupdatingCurrent) -> String {
        guard let start else { return "Time TBD" }
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: start)
    }
}

public struct ScheduleSnapshot: Codable, Equatable, Sendable {
    public var games: [Game]
    public var fetchedAt: Date
    public var day: String
    public var timeZone: String
    public var source: String
    public var limitedCoverage: Bool
    public var altitudeWarning: String?
    // Missing on v0.2 snapshots: retain existing NBA caches unchanged.
    public var guide: ScheduleGuide?
    public var selectedGuide: ScheduleGuide { guide ?? .nba }
    // Apply to saved snapshots too, without changing their data or freshness.
    public var displayGames: [Game] {
        guard selectedGuide == .nba else { return games }
        let chronological = Dates.sorted(games)
        return chronological.filter(\.isNuggets) + chronological.filter { !$0.isNuggets }
    }
    public init(games: [Game], fetchedAt: Date = Date(), day: String, timeZone: String, source: String, limitedCoverage: Bool) {
        self.games = games; self.fetchedAt = fetchedAt; self.day = day; self.timeZone = timeZone
        self.source = source; self.limitedCoverage = limitedCoverage
    }
}

public enum Dates {
    public static func upcomingSunday(from date: Date, timeZone: TimeZone) -> Date {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = timeZone
        let offset = (8 - calendar.component(.weekday, from: date)) % 7
        return calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: date))!
    }
    public static func key(_ date: Date, timeZone: TimeZone) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "en_US_POSIX"); f.timeZone = timeZone
        f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }
    public static func parse(_ value: String?) -> Date? {
        guard let value else { return nil }
        let f = ISO8601DateFormatter()
        if let date = f.date(from: value) { return date }
        f.formatOptions.insert(.withFractionalSeconds)
        if let date = f.date(from: value) { return date }
        let minutes = DateFormatter()
        minutes.locale = Locale(identifier: "en_US_POSIX")
        minutes.dateFormat = "yyyy-MM-dd'T'HH:mmXXXXX"
        minutes.isLenient = false
        return minutes.date(from: value)
    }
    public static func sorted(_ games: [Game]) -> [Game] {
        games.sorted { a, b in
            let x = a.start ?? .distantFuture, y = b.start ?? .distantFuture
            return x == y ? a.id < b.id : x < y
        }
    }
}

public enum FeedError: Error, LocalizedError {
    case invalid, http(Int), unavailable
    public var errorDescription: String? {
        switch self {
        case .invalid: return "The schedule source returned an unexpected format."
        case .http(let code): return "The schedule source returned HTTP \(code)."
        case .unavailable: return "Couldn’t refresh the schedule. Check your connection and try again."
        }
    }
}
