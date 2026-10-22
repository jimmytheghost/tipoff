import Foundation
import Testing
@testable import TipoffCore

private let leagueZone = TimeZone(identifier: "America/Denver")!
private func leagueRoot(_ name: String) throws -> [String: Any] {
    let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")!
    return try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: Any]
}
private func leagueData(_ root: [String: Any]) throws -> Data { try JSONSerialization.data(withJSONObject: root) }

@Test func nhlWeekFiltersSourceDayCountryAndTelemetry() throws {
    var root = try leagueRoot("nhl")
    root["clock"] = "12:00"; root["standings"] = "private-to-feed"
    let games = try LeagueFeedDecoder.nhl(leagueData(root), expectedDay: "2026-10-22")
    #expect(games.count == 12)
    #expect(games[0].away == "Nashville Predators")
    #expect(games[0].timeLabel(timeZone: leagueZone) == "5:00 PM")
    #expect(games[0].broadcasts.map(\.name) == ["NESN", "SCRIPPS"])
    #expect(games[1].broadcasts.map(\.name) == ["MSG"]) // Canadian home networks excluded.
    #expect(games.allSatisfy { $0.id.hasPrefix("nhl-") && !$0.isNuggets && !$0.isBroncos && $0.altitude == nil })
    let text = String(data: try JSONEncoder().encode(games), encoding: .utf8)!
    for excluded in ["clock", "standings", "score", "period", "odds", "private-to-feed"] { #expect(!text.contains(excluded)) }
}

@Test func nhlEmptyTBDAndMissingBroadcasts() throws {
    let empty = Data(#"{"numberOfGames":0,"gameWeek":[{"date":"2026-07-01","games":[]}]}"#.utf8)
    #expect(try LeagueFeedDecoder.nhl(empty, expectedDay: "2026-07-01").isEmpty)
    var root = try leagueRoot("nhl"), days = root["gameWeek"] as! [[String: Any]]
    var rows = days[0]["games"] as! [[String: Any]]
    rows[0]["gameScheduleState"] = "TBD"; rows[0].removeValue(forKey: "tvBroadcasts")
    days[0]["games"] = rows; root["gameWeek"] = days
    let game = try LeagueFeedDecoder.nhl(leagueData(root), expectedDay: "2026-10-22")[0]
    #expect(game.start == nil && game.broadcasts.isEmpty)
    #expect(game.scheduleDay == "2026-10-22")
}

@Test func nhlRejectsWrongDayPartialAndChangedSchema() throws {
    let original = try leagueRoot("nhl")
    #expect(throws: (any Error).self) { try LeagueFeedDecoder.nhl(leagueData(original), expectedDay: "2026-11-22") }
    var root = original; root["numberOfGames"] = 500
    #expect(throws: (any Error).self) { try LeagueFeedDecoder.nhl(leagueData(root), expectedDay: "2026-10-22") }
    for key in ["awayTeam", "startTimeUTC", "tvBroadcasts", "gameScheduleState"] {
        root = original; var days = root["gameWeek"] as! [[String: Any]], rows = days[0]["games"] as! [[String: Any]]
        rows[0][key] = "changed"; days[0]["games"] = rows; root["gameWeek"] = days
        #expect(throws: (any Error).self) { try LeagueFeedDecoder.nhl(leagueData(root), expectedDay: "2026-10-22") }
    }
    root = original; var days = root["gameWeek"] as! [[String: Any]], rows = days[0]["games"] as! [[String: Any]]
    rows[0]["tvBroadcasts"] = [["countryCode": "US", "newName": "NESN", "market": "H"]]
    days[0]["games"] = rows; root["gameWeek"] = days
    #expect(throws: (any Error).self) { try LeagueFeedDecoder.nhl(leagueData(root), expectedDay: "2026-10-22") }
}

@Test func mlbFixtureKeepsTVStreamingBrandsAndExcludesRadio() throws {
    let games = try LeagueFeedDecoder.mlb(leagueData(leagueRoot("mlb")), expectedDay: "2026-07-01")
    #expect(games.count == 14)
    #expect(games[0].broadcasts.map(\.name) == ["MASN", "Chicago Sports Network"])
    #expect(games.contains { $0.broadcasts.contains { $0.name == "Rockies.TV" } })
    #expect(games.allSatisfy { $0.id.hasPrefix("mlb-") && !$0.isNuggets && !$0.isBroncos && $0.altitude == nil })
    #expect(games.allSatisfy { $0.broadcasts.allSatisfy { !$0.name.contains(" AM") && !$0.name.contains(" FM") } })
}

@Test func mlbDoubleheadersTBDAndPostponementsKeepSeparateIdentity() throws {
    var root = try leagueRoot("mlb"), days = root["dates"] as! [[String: Any]], rows = days[0]["games"] as! [[String: Any]]
    var first = rows[0], second = rows[0]
    first["doubleHeader"] = "Y"; first["gameNumber"] = 1
    second["gamePk"] = 999; second["doubleHeader"] = "S"; second["gameNumber"] = 2
    second["status"] = ["startTimeTBD": true, "detailedState": "Postponed"]
    second["rescheduleDate"] = "2026-07-07T18:00:00Z" // Do not move a postponed row into a different selected day.
    days[0]["games"] = [first, second]; root["dates"] = days; root["totalGames"] = 2
    rows = []; let games = try LeagueFeedDecoder.mlb(leagueData(root), expectedDay: "2026-07-01")
    #expect(games.count == 2 && games[0].id != games[1].id)
    #expect(games[0].notice == "Game 1")
    #expect(games[1].notice == "Game 2 · Postponed")
    #expect(games[1].start == nil && games[1].scheduleDay == "2026-07-01")
}

@Test func mlbRejectsWrongDayPartialAndMalformedListings() throws {
    let original = try leagueRoot("mlb")
    #expect(throws: (any Error).self) { try LeagueFeedDecoder.mlb(leagueData(original), expectedDay: "2026-07-02") }
    var root = original; root["totalGames"] = 100
    #expect(throws: (any Error).self) { try LeagueFeedDecoder.mlb(leagueData(root), expectedDay: "2026-07-01") }
    for key in ["teams", "gameDate", "broadcasts", "status"] {
        root = original; var days = root["dates"] as! [[String: Any]], rows = days[0]["games"] as! [[String: Any]]
        rows[0][key] = "changed"; days[0]["games"] = rows; root["dates"] = days
        #expect(throws: (any Error).self) { try LeagueFeedDecoder.mlb(leagueData(root), expectedDay: "2026-07-01") }
    }
    root = original
    var days = root["dates"] as! [[String: Any]], rows = days[0]["games"] as! [[String: Any]]
    rows[0]["broadcasts"] = [["type": "unknown", "name": "Changed network", "isNational": true]]
    days[0]["games"] = rows; root["dates"] = days
    #expect(throws: (any Error).self) { try LeagueFeedDecoder.mlb(leagueData(root), expectedDay: "2026-07-01") }
    #expect(try LeagueFeedDecoder.mlb(Data(#"{"totalGames":0,"dates":[]}"#.utf8), expectedDay: "2026-07-01").isEmpty)
}

private final class LeagueProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let url = request.url!, mode = request.value(forHTTPHeaderField: "X-Tipoff-Test") ?? "valid"
            let isNHL = url.host == "api-web.nhle.com" || url.path.contains("hockey/nhl")
            let guide: ScheduleGuide = isNHL ? .nhl : .mlb
            let primaryDay = isNHL ? "2026-10-22" : "2026-07-01"
            let root: [String: Any]
            if url.host == "site.api.espn.com" {
                let query = URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!
                let day = query.first { $0.name == "dates" }!.value!
                let event: [String: Any] = ["id": "fallback", "date": primaryDay + "T20:00Z", "competitions": [[
                    "date": primaryDay + "T20:00Z", "timeValid": true,
                    "competitors": [["homeAway": "home", "team": ["displayName": "Home", "abbreviation": "H"]], ["homeAway": "away", "team": ["displayName": "Away", "abbreviation": "A"]]],
                    "broadcasts": [["market": "national", "names": ["Source TV"]]]]]]
                root = ["leagues": [["abbreviation": guide.title]], "events": day == primaryDay.replacingOccurrences(of: "-", with: "") ? [event] : []]
            } else if mode == "fallback" { root = ["schema": "changed"] }
            else if isNHL { root = try leagueRoot("nhl") }
            else {
                let day = URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!.first { $0.name == "date" }!.value!
                root = day == primaryDay ? try leagueRoot("mlb") : ["totalGames": 0, "dates": []]
            }
            let status = mode == "offline" ? 503 : 200
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: try leagueData(root))
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}
private func leagueProvider(_ mode: String) -> ScheduleProvider {
    let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [LeagueProtocol.self]
    config.httpAdditionalHeaders = ["X-Tipoff-Test": mode]
    return ScheduleProvider(session: URLSession(configuration: config))
}
@Test func leagueProvidersPreferPrimaryAndLabelFallback() async throws {
    for guide: ScheduleGuide in [.nhl, .mlb] {
        let day = Dates.parse(guide == .nhl ? "2026-10-22T18:00:00Z" : "2026-07-01T18:00:00Z")!
        let primary = try await leagueProvider("valid").load(day: day, timeZone: leagueZone, guide: guide)
        #expect(primary.source == (guide == .nhl ? "NHL.com" : "MLB.com"))
        #expect(primary.games.count == (guide == .nhl ? 12 : 14))
        let fallback = try await leagueProvider("fallback").load(day: day, timeZone: leagueZone, guide: guide)
        #expect(fallback.source == "ESPN · \(guide.title) fallback" && fallback.limitedCoverage)
        #expect(fallback.games.count == 1)
        #expect(fallback.games[0].id == guide.rawValue + "-espn-fallback")
        #expect(fallback.selectedGuide == guide && fallback.altitudeWarning == nil)
    }
}
@Test @MainActor func leagueTotalFailuresPreserveIsolatedScoreFreeCaches() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let cache = ScheduleCache(directory: directory)
    for guide: ScheduleGuide in [.nhl, .mlb] {
        let games = try guide == .nhl ? LeagueFeedDecoder.nhl(leagueData(leagueRoot("nhl")), expectedDay: "2026-10-22") : LeagueFeedDecoder.mlb(leagueData(leagueRoot("mlb")), expectedDay: "2026-07-01")
        var saved = ScheduleSnapshot(games: games, fetchedAt: Dates.parse("2026-01-01T00:00:00Z")!, day: Dates.key(Date(), timeZone: leagueZone), timeZone: leagueZone.identifier, source: "Saved primary", limitedCoverage: false)
        saved.guide = guide; try cache.write(saved)
        let store = ScheduleStore(provider: leagueProvider("offline"), cache: cache, timeZone: leagueZone, guide: guide)
        store.refresh()
        for _ in 0..<300 { if !store.refreshing { break }; try await Task.sleep(for: .milliseconds(10)) }
        #expect(store.isCached && store.error != nil && !store.refreshing)
        #expect(store.snapshot == saved)
        #expect(cache.read(day: saved.day, timeZone: saved.timeZone, guide: guide) == saved)
        let text = String(data: try JSONEncoder().encode(saved), encoding: .utf8)!.lowercased()
        for field in ["score", "period", "clock", "standings", "odds"] { #expect(!text.contains(field)) }
    }
    #expect(cache.read(day: Dates.key(Date(), timeZone: leagueZone), timeZone: leagueZone.identifier, guide: .wnba) == nil)
}
