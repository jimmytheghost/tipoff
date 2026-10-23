import Foundation
import Testing
@testable import TipoffCore

private let mountain = TimeZone(identifier: "America/Denver")!
private func date(_ iso: String) -> Date { Dates.parse(iso)! }
private func fixture(_ name: String) throws -> Data {
    try Data(contentsOf: Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures")!)
}
private func sample(day: String = "2026-10-20", source: String = "NBA.com") -> ScheduleSnapshot {
    ScheduleSnapshot(games: [], day: day, timeZone: mountain.identifier, source: source, limitedCoverage: false)
}

@Test func nuggetsAppearFirstForHomeAwayAndSavedSchedules() throws {
    let others = try FeedDecoder.espn(fixture("espn.json"))
    for home in [true, false] {
        for prefix in ["nba-", "espn-"] {
            let nuggets = Game(id: prefix + "denver", away: home ? "Pelicans" : "Nuggets",
                home: home ? "Nuggets" : "Pelicans", awayCode: home ? "NOP" : "DEN",
                homeCode: home ? "DEN" : "NOP", start: date("2026-10-21T05:00:00Z"),
                scheduleDay: "2026-10-20", broadcasts: [Broadcast(name: "ESPN", category: "National")])
            var snapshot = sample()
            snapshot.games = [others[2], nuggets, others[0], others[1]]
            let saved = try JSONDecoder().decode(ScheduleSnapshot.self, from: JSONEncoder().encode(snapshot))
            #expect(saved.displayGames.map(\.id) == [nuggets.id] + Dates.sorted(others).map(\.id))
            #expect(saved.fetchedAt == snapshot.fetchedAt)
            #expect(saved.games == snapshot.games)
            #expect(nuggets.isNuggets && !nuggets.isBroncos)
        }
    }
    var broncos = others[0]
    broncos.id = "nfl-espn-denver"; broncos.homeCode = "DEN"
    #expect(broncos.isBroncos && !broncos.isNuggets)
    var nfl = sample(); nfl.guide = .nfl; nfl.games = [broncos] + others
    #expect(nfl.displayGames == nfl.games)
    #expect(sample().displayGames.isEmpty)
}

@Test func nbaPageIncludesStreamingAndRadio() throws {
    let games = try FeedDecoder.nbaPage(fixture("nba-page.html"), expectedDay: "2026-10-20")
    #expect(games.count == 3)
    #expect(games.first?.awayCode == "BOS")
    #expect(games.first?.homeCode == "DET")
    #expect(games.first?.timeLabel(timeZone: mountain) == "1:00 PM")
    #expect(games[0].broadcasts.contains { $0.name == "Peacock" })
    #expect(games[0].broadcasts.contains { $0.category == "Home radio" })
    #expect(games[2].timeLabel(timeZone: mountain) == "7:30 PM")
}
@Test func nbaRejectsWrongDateAndChallengePage() throws {
    let data = try fixture("nba-page.html")
    #expect(throws: (any Error).self) { try FeedDecoder.nbaPage(data, expectedDay: "2026-10-21") }
    #expect(throws: (any Error).self) { try FeedDecoder.nbaPage(Data("Access denied".utf8), expectedDay: "2026-10-20") }
}
@Test func nbaRejectsPartialPagination() throws {
    let html = String(data: try fixture("nba-page.html"), encoding: .utf8)!.replacingOccurrences(of: "\"nextPageToken\": null", with: "\"nextPageToken\": \"page2\"")
    #expect(throws: (any Error).self) { try FeedDecoder.nbaPage(Data(html.utf8), expectedDay: "2026-10-20") }
}
@Test func nbaValidEmptyDay() throws {
    let html = #"<script id="__NEXT_DATA__">{"props":{"pageProps":{"selectedDate":"2026-10-20","gameCardFeed":{"modules":[]}}}}</script>"#
    #expect(try FeedDecoder.nbaPage(Data(html.utf8), expectedDay: "2026-10-20").isEmpty)
}
@Test func espnHandlesMinutePrecisionUTC() throws {
    let games = try FeedDecoder.espn(fixture("espn.json"))
    #expect(games.count == 3)
    #expect(games.first?.timeLabel(timeZone: mountain) == "1:00 PM")
    #expect(games[2].timeLabel(timeZone: mountain) == "7:30 PM")
}
@Test func unknownFeedIsNotAnEmptySchedule() {
    #expect(throws: (any Error).self) { try FeedDecoder.espn(Data("{}".utf8)) }
}
@Test func scoresNeverEnterEncodedModel() throws {
    let games = try FeedDecoder.nbaPage(fixture("nba-page.html"), expectedDay: "2026-10-20")
    let encoded = String(data: try JSONEncoder().encode(games), encoding: .utf8)!
    #expect(!encoded.lowercased().contains("score"))
    #expect(!encoded.contains("period"))
}
@Test func localDayIncludesPreviousUTCDateAndExcludesNextLocalDay() throws {
    var c = Calendar(identifier: .gregorian); c.timeZone = mountain
    let games = try FeedDecoder.espn(fixture("espn.json"))
    #expect(games[2].falls(on: date("2026-10-20T18:00:00Z"), calendar: c))
    #expect(!games[2].falls(on: date("2026-10-21T18:00:00Z"), calendar: c))
}
@Test func sourceDatesCoverMountainMidnightAndDST() {
    #expect(ScheduleProvider.sourceDays(day: date("2026-10-20T18:00:00Z"), timeZone: mountain) == ["2026-10-20", "2026-10-21"])
    #expect(ScheduleProvider.sourceDays(day: date("2026-03-08T18:00:00Z"), timeZone: mountain) == ["2026-03-08", "2026-03-09"])
    #expect(ScheduleProvider.sourceDays(day: date("2026-11-01T18:00:00Z"), timeZone: mountain) == ["2026-11-01", "2026-11-02"])
}
@Test func timeZoneFormattingHonorsDST() {
    let game = Game(id: "x", away: "A", home: "B", awayCode: "A", homeCode: "B", start: date("2026-12-01T02:00:00Z"), scheduleDay: "2026-11-30", broadcasts: [])
    #expect(game.timeLabel(timeZone: mountain) == "7:00 PM")
    #expect(game.timeLabel(timeZone: TimeZone(identifier: "America/New_York")!) == "9:00 PM")
}
@Test func cacheRoundTripAndIsolation() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let cache = ScheduleCache(directory: directory)
    let value = sample()
    try cache.write(value)
    #expect(cache.read(day: value.day, timeZone: value.timeZone) == value)
    #expect(cache.read(day: "2026-10-21", timeZone: value.timeZone) == nil)
    #expect(cache.read(day: value.day, timeZone: "America/New_York") == nil)
}
@Test func corruptCacheIsIgnored() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try Data("broken".utf8).write(to: directory.appendingPathComponent("2026-10-20-America_Denver.json"))
    #expect(ScheduleCache(directory: directory).read(day: "2026-10-20", timeZone: mountain.identifier) == nil)
}

private struct OfflineProvider: ScheduleLoading {
    func load(day: Date, timeZone: TimeZone) async throws -> ScheduleSnapshot { throw FeedError.unavailable }
}
private actor ControlledProvider: ScheduleLoading {
    var calls: [(Date, TimeZone, CheckedContinuation<ScheduleSnapshot, Error>)] = []
    func load(day: Date, timeZone: TimeZone) async throws -> ScheduleSnapshot {
        try await withCheckedThrowingContinuation { calls.append((day, timeZone, $0)) }
    }
    var count: Int { calls.count }
    func finish(_ index: Int, source: String) {
        let (day, zone, continuation) = calls[index]
        continuation.resume(returning: ScheduleSnapshot(games: [], day: Dates.key(day, timeZone: zone), timeZone: zone.identifier, source: source, limitedCoverage: false))
    }
}
@MainActor private func waitUntil(_ condition: () async -> Bool) async throws {
    let deadline = Date().addingTimeInterval(3)
    while !(await condition()) && Date() < deadline { try await Task.sleep(for: .milliseconds(5)) }
    #expect(await condition())
}
@Test @MainActor func offlineRefreshPreservesSavedListings() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let cache = ScheduleCache(directory: directory)
    let value = sample(day: Dates.key(Date(), timeZone: mountain))
    try cache.write(value)
    let store = ScheduleStore(provider: OfflineProvider(), cache: cache, timeZone: mountain)
    store.refresh()
    try await waitUntil { !store.refreshing }
    #expect(store.snapshot == value)
    #expect(store.isCached)
    #expect(store.error != nil)
    #expect(cache.read(day: value.day, timeZone: mountain.identifier) == value)
}
@Test @MainActor func olderRequestCannotReplaceNewDay() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let provider = ControlledProvider()
    let store = ScheduleStore(provider: provider, cache: ScheduleCache(directory: directory), timeZone: mountain)
    store.refresh()
    try await waitUntil { await provider.count == 1 }
    store.moveDay(1)
    try await waitUntil { await provider.count == 2 }
    await provider.finish(1, source: "New day")
    try await waitUntil { !store.refreshing }
    await provider.finish(0, source: "Old day")
    // The provider intentionally ignores cancellation; store must reject that result itself.
    try await Task.sleep(for: .milliseconds(20))
    #expect(store.snapshot?.source == "New day")
    #expect(store.snapshot?.day == Dates.key(store.selectedDate, timeZone: mountain))
}
@Test func postponementDoesNotExposeGameStatusOrScores() throws {
    let html = String(data: try fixture("nba-page.html"), encoding: .utf8)!.replacingOccurrences(of: "3:00 pm ET", with: "Postponed")
    let games = try FeedDecoder.nbaPage(Data(html.utf8), expectedDay: "2026-10-20")
    #expect(games.first?.notice == "Postponed")
}
