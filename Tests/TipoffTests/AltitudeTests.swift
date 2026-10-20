import Foundation
import Testing
@testable import TipoffCore

private let mountain = TimeZone(identifier: "America/Denver")!
private func altitudeFixture() throws -> Data {
    try Data(contentsOf: Bundle.module.url(forResource: "altitude-page", withExtension: "html", subdirectory: "Fixtures")!)
}
private func schedule() throws -> AltitudeSchedule { try AltitudeDecoder.page(altitudeFixture()) }
private func game(day: String = "2026-10-24", opponent: String = "NOP", denverHome: Bool = true, hour: String = "01:00:00") -> Game {
    Game(id: "nba-test", away: denverHome ? "Pelicans" : "Nuggets", home: denverHome ? "Nuggets" : "Pelicans",
        awayCode: denverHome ? opponent : "DEN", homeCode: denverHome ? "DEN" : opponent,
        start: Dates.parse(day + "T" + hour + "Z")!.addingTimeInterval(86400), scheduleDay: day,
        broadcasts: [Broadcast(name: "League Pass", category: "Subscription")])
}

@Test func altitudeParsesFullSeasonAndRegionalNotes() throws {
    let value = try schedule()
    #expect(value.entries.count == 85)
    let entry = try #require(value.entries.first { $0.day == "2026-10-24" })
    #expect(entry.opponentCode == "NOP")
    #expect(entry.denverHome)
    #expect(entry.networks == ["ALT", "Altitude+", "KTVD-20*"])
    #expect(entry.pregame == Dates.parse("2026-10-25T00:00:00Z"))
    #expect(entry.postgame == Dates.parse("2026-10-25T03:30:00Z"))
    #expect(entry.notes.first?.contains("exclusive in the Denver DMA") == true)
}
@Test func altitudeHandlesMultipleStationsAndNeutralSites() throws {
    let value = try schedule()
    let multiple = try #require(value.entries.first { $0.day == "2026-11-02" })
    #expect(multiple.networks == ["ALT2", "Altitude+", "KUSA-9*", "KTVD-20*"])
    let neutral = try #require(value.entries.first { $0.day == "2026-11-07" })
    #expect(neutral.opponentCode == "IND")
    #expect(!neutral.denverHome)
    let outer = try #require(value.entries.first { $0.day == "2026-11-09" })
    #expect(outer.notes.first?.hasPrefix("^") == true)
}
@Test func nationalOnlyGameDoesNotInventAltitudeCoverage() throws {
    let value = try schedule()
    let row = try #require(value.entries.first { $0.day == "2026-10-22" })
    #expect(row.networks == ["ESPN"])
    #expect(row.pregame == nil)
    let input = game(day: "2026-10-22", opponent: "OKC", denverHome: false, hour: "01:30:00")
    let result = AltitudeDecoder.enrich(input, with: value, saved: false)
    #expect(result.warning == nil)
    #expect(!result.game.broadcasts.contains { $0.name == "Altitude+" })
}
@Test func matchedNuggetsGameGetsSupplementWithoutLosingPrimaryListings() throws {
    let result = AltitudeDecoder.enrich(game(), with: try schedule(), saved: false)
    #expect(result.warning == nil)
    #expect(result.game.broadcasts.map(\.name) == ["Altitude", "Altitude+", "KTVD-20*", "League Pass"])
    #expect(result.game.altitude?.notes.isEmpty == false)
    #expect(result.game.start == game().start)
}
@Test func supplementRequiresOpponentVenueAndTipoffAgreement() throws {
    let value = try schedule()
    for input in [game(opponent: "LAL"), game(denverHome: false), game(hour: "02:00:00")] {
        let result = AltitudeDecoder.enrich(input, with: value, saved: false)
        #expect(result.game == input)
        #expect(result.warning != nil)
    }
    let duplicate = AltitudeSchedule(entries: value.entries + value.entries, fetchedAt: value.fetchedAt)
    #expect(AltitudeDecoder.enrich(game(), with: duplicate, saved: false).game.altitude == nil)
}
@Test func supplementNeverTouchesOtherTeams() throws {
    var input = game(); input.homeCode = "BOS"
    let result = AltitudeDecoder.enrich(input, with: try schedule(), saved: false)
    #expect(result.game == input)
    #expect(result.warning == nil)
}
@Test func alreadyListedBroadcastersAreNotDuplicated() throws {
    var input = game()
    input.broadcasts.append(Broadcast(name: "Altitude+", category: "Home streaming"))
    let result = AltitudeDecoder.enrich(input, with: try schedule(), saved: true)
    #expect(result.game.broadcasts.filter { $0.name == "Altitude+" }.count == 1)
    #expect(result.game.altitude?.saved == true)
}
@Test func altitudeUsesMountainDSTAndSkipsUnassignedCupRows() throws {
    let value = try schedule()
    let winter = try #require(value.entries.first { $0.day == "2027-01-02" })
    #expect(winter.start == Dates.parse("2027-01-02T22:00:00Z"))
    #expect(value.entries.allSatisfy { $0.day != "TBD" })
}
@Test func malformedAltitudePageDoesNotBecomeEmptySchedule() throws {
    #expect(throws: (any Error).self) { try AltitudeDecoder.page(Data("<html>Access denied</html>".utf8)) }
    let html = String(data: try altitudeFixture(), encoding: .utf8)!
    #expect(throws: (any Error).self) { try AltitudeDecoder.page(Data(html.replacingOccurrences(of: "/nuggets-broadcasts", with: "/avs-broadcasts").utf8)) }
    #expect(throws: (any Error).self) { try AltitudeDecoder.page(Data(html.replacingOccurrences(of: "<th>Networks</th>", with: "<th>Unknown</th>").utf8)) }
    #expect(throws: (any Error).self) { try AltitudeDecoder.page(Data(html.replacingOccurrences(of: "* Games on KUSA-9", with: "Games on KUSA-9").utf8)) }
}
@Test func altitudeMetadataSurvivesCacheWithoutScores() throws {
    var input = ScheduleSnapshot(games: [AltitudeDecoder.enrich(game(), with: try schedule(), saved: true).game],
        day: "2026-10-24", timeZone: mountain.identifier, source: "NBA.com + Altitude", limitedCoverage: false)
    input.altitudeWarning = "Saved Altitude listings"
    let data = try JSONEncoder().encode(input)
    #expect(!String(data: data, encoding: .utf8)!.lowercased().contains("score"))
    #expect(try JSONDecoder().decode(ScheduleSnapshot.self, from: data) == input)
}

private final class AltitudeUnavailableProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("unavailable".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
@Test func failedAltitudeRefreshRetainsSavedSupplementAndAge() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let cache = directory.appendingPathComponent("Altitude.json")
    let old = try schedule()
    let original = try JSONEncoder().encode(old)
    try original.write(to: cache)
    let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [AltitudeUnavailableProtocol.self]
    let result = try await AltitudeProvider(session: URLSession(configuration: config), cacheURL: cache).load()
    #expect(result.saved)
    #expect(result.warning != nil)
    #expect(result.schedule?.fetchedAt == old.fetchedAt)
    #expect(try Data(contentsOf: cache) == original)
}
@Test func failedAltitudeWithoutCacheStillReportsMissingCoverage() async throws {
    let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [AltitudeUnavailableProtocol.self]
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let result = try await AltitudeProvider(session: URLSession(configuration: config), cacheURL: directory.appendingPathComponent("Altitude.json")).load()
    #expect(result.schedule == nil)
    #expect(result.warning != nil)
    #expect(!result.saved)
}

@Test func changedGameDoesNotUseOldAltitudeShowTimes() throws {
    var input = game(); input.notice = "Postponed"
    let result = AltitudeDecoder.enrich(input, with: try schedule(), saved: false)
    #expect(result.game == input)
    #expect(result.warning != nil)
}
