import Foundation
import Testing
@testable import TipoffCore

private let nflZone = TimeZone(identifier: "America/Denver")!
private func nflFixture(_ name: String) throws -> Data {
    try Data(contentsOf: Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")!)
}
private func nflRoot(_ name: String = "nfl") throws -> [String: Any] {
    try JSONSerialization.jsonObject(with: nflFixture(name)) as! [String: Any]
}
private func encoded(_ root: [String: Any]) throws -> Data { try JSONSerialization.data(withJSONObject: root) }

@Test func nflFixturePreservesSuppliedNetworksAndDenverIdentity() throws {
    let games = try FeedDecoder.espn(nflFixture("nfl"), guide: .nfl)
    let denver = try #require(games.first(where: { $0.isBroncos }))
    #expect(denver.away == "Denver Broncos")
    #expect(denver.homeCode == "ARI")
    #expect(denver.timeLabel(timeZone: nflZone) == "2:05 PM")
    #expect(denver.broadcasts.map(\.name) == ["CBS"])
    #expect(denver.altitude == nil)
    #expect(games.allSatisfy { $0.id.hasPrefix("nfl-espn-") })
}

@Test func nflRejectsSchemaChangesAndWrongLeague() throws {
    for replacement in ["NBA", ""] {
        var root = try nflRoot(); root["leagues"] = [["abbreviation": replacement]]
        #expect(throws: (any Error).self) { try FeedDecoder.espn(encoded(root), guide: .nfl) }
    }
    for field in ["competitors", "date", "broadcasts", "geoBroadcasts"] {
        var root = try nflRoot(); var events = root["events"] as! [[String: Any]]
        var competitions = events[0]["competitions"] as! [[String: Any]]
        competitions[0][field] = "schema changed"; events[0]["competitions"] = competitions; root["events"] = events
        #expect(throws: (any Error).self) { try FeedDecoder.espn(encoded(root), guide: .nfl) }
    }
    var root = try nflRoot(); root["events"] = Array(repeating: (root["events"] as! [[String: Any]])[0], count: 100)
    #expect(throws: (any Error).self) { try FeedDecoder.espn(encoded(root), guide: .nfl) }
}

@Test func nflValidEmptyAndUnknownTimeAreDistinct() throws {
    let empty = Data(#"{"leagues":[{"abbreviation":"NFL"}],"events":[]}"#.utf8)
    #expect(try FeedDecoder.espn(empty, guide: .nfl).isEmpty)
    var root = try nflRoot(); var events = root["events"] as! [[String: Any]]
    var competitions = events[0]["competitions"] as! [[String: Any]]
    competitions[0]["timeValid"] = false; events[0]["competitions"] = competitions; root["events"] = events
    let game = try FeedDecoder.espn(encoded(root), guide: .nfl)[0]
    #expect(game.start == nil)
    #expect(game.timeLabel() == "Time TBD")
    #expect(game.scheduleDay == "2026-10-25")
}
@Test func nflCacheExcludesTelemetryAndSeparatesGuides() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let cache = ScheduleCache(directory: directory)
    var root = try nflRoot(); root["score"] = 99; root["clock"] = "12:00"; root["standings"] = ["wins": 5]
    var events = root["events"] as! [[String: Any]]
    var competitions = events[0]["competitions"] as! [[String: Any]]
    var competitors = competitions[0]["competitors"] as! [[String: Any]]
    competitors[0]["score"] = "99"; competitors[0]["records"] = [["summary": "5-1"]]
    competitions[0]["competitors"] = competitors
    competitions[0]["status"] = ["displayClock": "12:00", "period": 2, "type": ["name": "STATUS_IN_PROGRESS"]]
    events[0]["competitions"] = competitions; root["events"] = events
    let games = try FeedDecoder.espn(encoded(root), guide: .nfl)
    #expect(games[0].notice == nil)
    for guide in ScheduleGuide.allCases {
        var snapshot = ScheduleSnapshot(games: guide == .nba ? [] : games, day: "2026-10-25", timeZone: nflZone.identifier, source: guide.title, limitedCoverage: true)
        snapshot.guide = guide == .nba ? nil : guide
        try cache.write(snapshot)
        #expect(cache.read(day: snapshot.day, timeZone: snapshot.timeZone, guide: guide) == snapshot)
        let text = String(data: try JSONEncoder().encode(snapshot), encoding: .utf8)!.lowercased()
        for excluded in ["score", "clock", "standings", "period", "wins"] { #expect(!text.contains(excluded)) }
    }
    for guide in ScheduleGuide.allCases {
        #expect(cache.read(day: "2026-10-25", timeZone: nflZone.identifier, guide: guide)?.source == guide.title)
    }
}

private final class NFLFixtureProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
            var root: [String: Any]
            root = try nflRoot()
            if query["dates"] != "20261025" { root["events"] = [] }
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: try encoded(root))
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}
private func nflProvider() -> ScheduleProvider {
    let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [NFLFixtureProtocol.self]
    return ScheduleProvider(session: URLSession(configuration: config))
}
@Test func nflProviderFiltersLocalDaysAndPrioritizesBroncos() async throws {
    let day = Dates.parse("2026-10-25T18:00:00Z")!
    let result = try await nflProvider().load(day: day, timeZone: nflZone, guide: .nfl)
    #expect(result.games.count == 2)
    #expect(result.games.first?.isBroncos == true)
    #expect(result.selectedGuide == .nfl)
    #expect(result.limitedCoverage)
    #expect(result.altitudeWarning == nil)
}

private actor GuideControlledProvider: ScheduleLoading {
    var calls: [(Date, TimeZone, ScheduleGuide, CheckedContinuation<ScheduleSnapshot, Error>)] = []
    func load(day: Date, timeZone: TimeZone) async throws -> ScheduleSnapshot { throw FeedError.unavailable }
    func load(day: Date, timeZone: TimeZone, guide: ScheduleGuide) async throws -> ScheduleSnapshot {
        try await withCheckedThrowingContinuation { calls.append((day, timeZone, guide, $0)) }
    }
    var count: Int { calls.count }
    func finish(_ index: Int, fail: Bool = false) {
        let (day, zone, guide, continuation) = calls[index]
        if fail { continuation.resume(throwing: FeedError.invalid); return }
        var snapshot = ScheduleSnapshot(games: [], day: Dates.key(day, timeZone: zone), timeZone: zone.identifier, source: guide.title, limitedCoverage: true)
        snapshot.guide = guide
        continuation.resume(returning: snapshot)
    }
}
@MainActor private func nflWait(_ condition: () async -> Bool) async throws {
    for _ in 0..<300 { if await condition() { return }; try await Task.sleep(for: .milliseconds(10)) }
    #expect(await condition())
}
@Test(arguments: [ScheduleGuide.nfl, .wnba, .nhl, .mlb]) @MainActor func guideSwitchRejectsOldResponseAndRetainsCacheOnSchemaFailure(_ targetGuide: ScheduleGuide) async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let cache = ScheduleCache(directory: directory), provider = GuideControlledProvider()
    let store = ScheduleStore(provider: provider, cache: cache, timeZone: nflZone)
    store.refresh(); try await nflWait { await provider.count == 1 }
    store.selectGuide(targetGuide); try await nflWait { await provider.count == 2 }
    await provider.finish(1); try await nflWait { !store.refreshing }
    let saved = store.snapshot
    await provider.finish(0)
    try await Task.sleep(for: .milliseconds(20))
    #expect(store.snapshot == saved)
    store.selectGuide(.nba); try await nflWait { await provider.count == 3 }
    #expect(store.snapshot == nil)
    store.selectGuide(targetGuide); try await nflWait { await provider.count == 4 }
    #expect(store.snapshot == saved)
    await provider.finish(3, fail: true); try await nflWait { !store.refreshing }
    await provider.finish(2)
    #expect(store.isCached)
    #expect(store.error != nil)
    #expect(store.snapshot == saved)
    #expect(cache.read(day: saved!.day, timeZone: nflZone.identifier, guide: targetGuide) == saved)
}


@Test func nflDoesNotInferStreamingOrReuseForeignBroadcasts() throws {
    var root = try nflRoot(); var events = root["events"] as! [[String: Any]]
    var competitions = events[0]["competitions"] as! [[String: Any]]
    competitions[0]["geoBroadcasts"] = [
        ["media": ["shortName": "Foreign TV"], "region": "gb"],
        ["media": ["shortName": "Denver Radio"], "region": "us", "type": ["shortName": "Radio"]]
    ]
    events[0]["competitions"] = competitions; root["events"] = events
    let game = try FeedDecoder.espn(encoded(root), guide: .nfl)[0]
    #expect(game.broadcasts.map(\.name) == ["Denver Radio"])
    #expect(game.broadcasts[0].category.lowercased().contains("radio"))
    #expect(!game.broadcasts.contains { $0.name == "Altitude" || $0.name == "Paramount+" })
}
@Test func nflChangedBroadcastEntryDoesNotSilentlyLoseCachedListings() throws {
    var root = try nflRoot(); var events = root["events"] as! [[String: Any]]
    var competitions = events[0]["competitions"] as! [[String: Any]]
    competitions[0]["geoBroadcasts"] = [["renamedMedia": ["name": "CBS"]]]
    events[0]["competitions"] = competitions; root["events"] = events
    #expect(throws: (any Error).self) { try FeedDecoder.espn(encoded(root), guide: .nfl) }
}

@Test func guidesContainOnlySports() {
    #expect(ScheduleGuide.allCases == [.nba, .nfl, .wnba, .nhl, .mlb])
    #expect(ScheduleGuide(rawValue: "broncos") == nil)
}

@Test func sundayShortcutUsesLocalCalendarAcrossDSTAndYearBoundary() {
    let cases = [
        ("2026-10-20T18:00:00Z", "2026-10-25T06:00:00Z"),
        ("2026-10-25T18:00:00Z", "2026-10-25T06:00:00Z"),
        ("2026-10-26T18:00:00Z", "2026-11-01T06:00:00Z"),
        ("2026-03-07T19:00:00Z", "2026-03-08T07:00:00Z"),
        ("2026-12-31T19:00:00Z", "2027-01-03T07:00:00Z"),
        // UTC is already Sunday, but Denver is still Saturday.
        ("2026-10-25T02:00:00Z", "2026-10-25T06:00:00Z")
    ]
    for (input, expected) in cases {
        #expect(Dates.upcomingSunday(from: Dates.parse(input)!, timeZone: nflZone) == Dates.parse(expected))
    }
}
@Test @MainActor func sundayShortcutTargetsUpcomingSundayFromTodayRatherThanBrowsedDate() {
    var snapshot = ScheduleSnapshot(games: [], day: "2026-12-15", timeZone: nflZone.identifier, source: "Preview", limitedCoverage: true)
    snapshot.guide = .nfl
    let store = ScheduleStore(timeZone: nflZone, previewSnapshot: snapshot)
    #expect(!store.isSunday)
    store.sunday(now: Dates.parse("2026-10-20T18:00:00Z")!)
    #expect(store.selectedDate == Dates.parse("2026-10-25T06:00:00Z"))
    #expect(store.isSunday)
    #expect(store.guide == .nfl)
}
