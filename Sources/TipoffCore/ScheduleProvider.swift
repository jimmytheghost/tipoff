import Foundation

public protocol ScheduleLoading: Sendable {
    func load(day: Date, timeZone: TimeZone) async throws -> ScheduleSnapshot
    func load(day: Date, timeZone: TimeZone, guide: ScheduleGuide) async throws -> ScheduleSnapshot
}

public extension ScheduleLoading {
    func load(day: Date, timeZone: TimeZone, guide: ScheduleGuide) async throws -> ScheduleSnapshot {
        guard guide == .nba else { throw FeedError.unavailable }
        return try await load(day: day, timeZone: timeZone)
    }
}

public actor ScheduleProvider: ScheduleLoading {
    private let altitude = AltitudeProvider()
    private let session: URLSession
    public init(session: URLSession? = nil) {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 25
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = session ?? URLSession(configuration: config)
    }
    // Both services group games by Eastern date. Fetch all such dates intersecting the user's day.
    public static func sourceDays(day: Date, timeZone: TimeZone) -> [String] {
        var local = Calendar(identifier: .gregorian); local.timeZone = timeZone
        let start = local.startOfDay(for: day)
        let end = local.date(byAdding: .day, value: 1, to: start)!.addingTimeInterval(-1)
        var eastern = Calendar(identifier: .gregorian); eastern.timeZone = TimeZone(identifier: "America/New_York")!
        var cursor = eastern.startOfDay(for: start)
        var days: [String] = []
        while cursor <= end {
            days.append(Dates.key(cursor, timeZone: eastern.timeZone))
            cursor = eastern.date(byAdding: .day, value: 1, to: cursor)!
        }
        return days
    }
    public func load(day: Date, timeZone: TimeZone) async throws -> ScheduleSnapshot {
        let days = Self.sourceDays(day: day, timeZone: timeZone)
        let games: [Game]
        let source: String
        let limited: Bool
        do {
            games = try await fetchDays(days, nba: true)
            source = "NBA.com"; limited = false
        } catch {
            games = try await fetchDays(days, nba: false)
            source = "ESPN fallback"; limited = true
        }
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = timeZone
        var seen = Set<String>()
        var selected = games.filter { $0.falls(on: day, calendar: calendar) && seen.insert($0.id).inserted }
        var warning: String?
        var usedAltitude = false
        if selected.contains(where: { $0.homeCode == "DEN" || $0.awayCode == "DEN" }) {
            let supplement = try await altitude.load()
            warning = supplement.warning
            if let schedule = supplement.schedule {
                selected = selected.map { game in
                    let result = AltitudeDecoder.enrich(game, with: schedule, saved: supplement.saved)
                    if let issue = result.warning { warning = [warning, issue].compactMap { $0 }.joined(separator: " ") }
                    if result.game.altitude != nil { usedAltitude = true }
                    return result.game
                }
            }
        }
        var snapshot = ScheduleSnapshot(games: Dates.sorted(selected), day: Dates.key(day, timeZone: timeZone),
            timeZone: timeZone.identifier, source: source + (usedAltitude ? " + Altitude" : ""), limitedCoverage: limited)
        snapshot.altitudeWarning = warning
        return snapshot
    }
    public func load(day: Date, timeZone: TimeZone, guide: ScheduleGuide) async throws -> ScheduleSnapshot {
        if guide == .nba { return try await load(day: day, timeZone: timeZone) }
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = timeZone
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let days = Self.sourceDays(day: day, timeZone: timeZone)
        var games: [Game] = []
        let source: String
        let limited: Bool
        if guide == .nhl || guide == .mlb {
            do {
                for sourceDay in days {
                    let address = guide == .nhl ? "https://api-web.nhle.com/v1/schedule/\(sourceDay)"
                        : "https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=\(sourceDay)&hydrate=broadcasts"
                    let data = try await fetch(URL(string: address)!)
                    games += try guide == .nhl ? LeagueFeedDecoder.nhl(data, expectedDay: sourceDay) : LeagueFeedDecoder.mlb(data, expectedDay: sourceDay)
                }
                source = guide == .nhl ? "NHL.com" : "MLB.com"
                limited = guide == .nhl // The league TV list can omit streaming options.
            } catch {
                games = try await fetchESPNDays(days, guide: guide)
                source = "ESPN · \(guide.title) fallback"; limited = true
            }
        } else {
            games = try await fetchESPNDays(days, guide: guide)
            source = "ESPN · \(guide.title)"; limited = true
        }
        var seen = Set<String>()
        let selected = games.filter { game in
            let inWindow: Bool
            if let time = game.start { inWindow = time >= start && time < end }
            else { inWindow = game.scheduleDay >= Dates.key(start, timeZone: timeZone) && game.scheduleDay < Dates.key(end, timeZone: timeZone) }
            return inWindow && seen.insert(game.id).inserted
        }
        var snapshot = ScheduleSnapshot(games: selected.sorted {
            if guide == .nfl && $0.isBroncos != $1.isBroncos { return $0.isBroncos }
            let dayA = $0.start.map { Dates.key($0, timeZone: timeZone) } ?? $0.scheduleDay
            let dayB = $1.start.map { Dates.key($0, timeZone: timeZone) } ?? $1.scheduleDay
            if dayA != dayB { return dayA < dayB }
            let a = $0.start ?? .distantFuture, b = $1.start ?? .distantFuture
            return a == b ? $0.id < $1.id : a < b
        }, day: Dates.key(day, timeZone: timeZone), timeZone: timeZone.identifier,
            source: source, limitedCoverage: limited)
        snapshot.guide = guide
        return snapshot
    }
    private func fetchESPNDays(_ days: [String], guide: ScheduleGuide) async throws -> [Game] {
        var games: [Game] = []
        for day in days {
            let address = "https://site.api.espn.com/apis/site/v2/sports/\(guide.espnPath)/scoreboard?dates=\(day.replacingOccurrences(of: "-", with: ""))&limit=100"
            let decoded = try FeedDecoder.espn(await fetch(URL(string: address)!), guide: guide)
            guard decoded.allSatisfy({ $0.scheduleDay == day }) else { throw FeedError.invalid }
            games += decoded
        }
        return games
    }
    private func fetch(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 Tipoff/0.4", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw FeedError.invalid }
        guard http.statusCode == 200 else { throw FeedError.http(http.statusCode) }
        return data
    }
    private func fetchDays(_ days: [String], nba: Bool) async throws -> [Game] {
        try await withThrowingTaskGroup(of: [Game].self) { group in
            for day in days {
                group.addTask { [session] in
                    let address = nba ? "https://www.nba.com/games?date=\(day)"
                        : "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard?dates=\(day.replacingOccurrences(of: "-", with: ""))&limit=100"
                    var request = URLRequest(url: URL(string: address)!)
                    request.setValue("Mozilla/5.0 Tipoff/0.4", forHTTPHeaderField: "User-Agent")
                    request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
                    let (data, response) = try await session.data(for: request)
                    guard let http = response as? HTTPURLResponse else { throw FeedError.invalid }
                    guard http.statusCode == 200 else { throw FeedError.http(http.statusCode) }
                    return try nba ? FeedDecoder.nbaPage(data, expectedDay: day) : FeedDecoder.espn(data)
                }
            }
            var all: [Game] = []
            for try await games in group { all += games }
            return all
        }
    }
}

public struct ScheduleCache: Sendable {
    public let directory: URL
    public init(directory: URL? = nil) {
        self.directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Tipoff/Schedules", isDirectory: true)
    }
    private func url(day: String, timeZone: String, guide: ScheduleGuide = .nba) -> URL {
        let zone = timeZone.replacingOccurrences(of: "/", with: "_")
        return directory.appendingPathComponent("\(guide == .nba ? "" : guide.rawValue + "-")\(day)-\(zone).json")
    }
    public func read(day: String, timeZone: String, guide: ScheduleGuide = .nba) -> ScheduleSnapshot? {
        guard let data = try? Data(contentsOf: url(day: day, timeZone: timeZone, guide: guide)),
              let snapshot = try? JSONDecoder().decode(ScheduleSnapshot.self, from: data),
              snapshot.day == day, snapshot.timeZone == timeZone, snapshot.selectedGuide == guide else { return nil }
        return snapshot
    }
    public func write(_ snapshot: ScheduleSnapshot) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(snapshot).write(to: url(day: snapshot.day, timeZone: snapshot.timeZone, guide: snapshot.selectedGuide), options: .atomic)
        // Bound the cache; retain at most 45 daily snapshots.
        let files = try FileManager.default.contentsOfDirectory(at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey]).filter { $0.pathExtension == "json" }
        let sorted = files.sorted {
            let a = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let b = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return a > b
        }
        for file in sorted.dropFirst(45) { try? FileManager.default.removeItem(at: file) }
    }
}
