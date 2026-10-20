import Foundation

public protocol ScheduleLoading: Sendable {
    func load(day: Date, timeZone: TimeZone) async throws -> ScheduleSnapshot
}

public actor ScheduleProvider: ScheduleLoading {
    private let session: URLSession
    public init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 25
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config)
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
        let selected = games.filter { $0.falls(on: day, calendar: calendar) && seen.insert($0.id).inserted }
        return ScheduleSnapshot(games: Dates.sorted(selected), day: Dates.key(day, timeZone: timeZone),
            timeZone: timeZone.identifier, source: source, limitedCoverage: limited)
    }
    private func fetchDays(_ days: [String], nba: Bool) async throws -> [Game] {
        try await withThrowingTaskGroup(of: [Game].self) { group in
            for day in days {
                group.addTask { [session] in
                    let address = nba ? "https://www.nba.com/games?date=\(day)"
                        : "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard?dates=\(day.replacingOccurrences(of: "-", with: ""))&limit=100"
                    var request = URLRequest(url: URL(string: address)!)
                    request.setValue("Mozilla/5.0 Tipoff/0.1", forHTTPHeaderField: "User-Agent")
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
    private func url(day: String, timeZone: String) -> URL {
        let zone = timeZone.replacingOccurrences(of: "/", with: "_")
        return directory.appendingPathComponent("\(day)-\(zone).json")
    }
    public func read(day: String, timeZone: String) -> ScheduleSnapshot? {
        guard let data = try? Data(contentsOf: url(day: day, timeZone: timeZone)),
              let snapshot = try? JSONDecoder().decode(ScheduleSnapshot.self, from: data),
              snapshot.day == day, snapshot.timeZone == timeZone else { return nil }
        return snapshot
    }
    public func write(_ snapshot: ScheduleSnapshot) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(snapshot).write(to: url(day: snapshot.day, timeZone: snapshot.timeZone), options: .atomic)
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
