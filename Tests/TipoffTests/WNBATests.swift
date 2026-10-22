import Foundation
import Testing
@testable import TipoffCore

private let wnbaZone = TimeZone(identifier: "America/Denver")!
private func wnbaRoot() throws -> [String: Any] {
    let url = Bundle.module.url(forResource: "wnba", withExtension: "json", subdirectory: "Fixtures")!
    return try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: Any]
}
private func wnbaData(_ root: [String: Any]) throws -> Data { try JSONSerialization.data(withJSONObject: root) }

@Test func wnbaPreservesSourceNetworksWithoutDenverEmphasis() throws {
    let games = try FeedDecoder.espn(wnbaData(wnbaRoot()), guide: .wnba)
    #expect(games.count == 3)
    #expect(games[0].broadcasts.map(\.name) == ["CBS", "Paramount+"])
    #expect(games[1].broadcasts.map(\.name) == ["NBA TV", "MNMT", "Victory+ MIN"])
    #expect(games[2].broadcasts.map(\.name) == ["ESPN", "Disney+"])
    #expect(games[2].timeLabel(timeZone: wnbaZone) == "6:00 PM")
    #expect(games.allSatisfy { $0.id.hasPrefix("wnba-espn-") && !$0.isNuggets && !$0.isBroncos && $0.altitude == nil })
    var game = games[0]; game.homeCode = "DEN"
    #expect(!game.isNuggets && !game.isBroncos)
}

@Test func wnbaRejectsWrongLeagueMalformedAndTruncatedFeeds() throws {
    for league in ["NBA", "NFL", "", "MLB"] {
        var root = try wnbaRoot(); root["leagues"] = [["abbreviation": league]]
        #expect(throws: (any Error).self) { try FeedDecoder.espn(wnbaData(root), guide: .wnba) }
    }
    for key in ["competitors", "date", "geoBroadcasts", "broadcasts"] {
        var root = try wnbaRoot(), events = root["events"] as! [[String: Any]]
        var competitions = events[0]["competitions"] as! [[String: Any]]
        competitions[0][key] = "changed schema"; events[0]["competitions"] = competitions; root["events"] = events
        #expect(throws: (any Error).self) { try FeedDecoder.espn(wnbaData(root), guide: .wnba) }
    }
    var root = try wnbaRoot(); root["events"] = Array(repeating: (root["events"] as! [[String: Any]])[0], count: 100)
    #expect(throws: (any Error).self) { try FeedDecoder.espn(wnbaData(root), guide: .wnba) }
    #expect(throws: (any Error).self) { try FeedDecoder.espn(Data("<html>unavailable</html>".utf8), guide: .wnba) }
}

@Test func wnbaEmptyTBDAndPostponedSchedulesRemainScoreFree() throws {
    var root = try wnbaRoot(); root["events"] = []
    #expect(try FeedDecoder.espn(wnbaData(root), guide: .wnba).isEmpty)
    root = try wnbaRoot(); var events = root["events"] as! [[String: Any]]
    var competitions = events[0]["competitions"] as! [[String: Any]]
    competitions[0]["timeValid"] = false
    events[0]["competitions"] = competitions; root["events"] = events
    let tbd = try FeedDecoder.espn(wnbaData(root), guide: .wnba)[0]
    #expect(tbd.start == nil && tbd.scheduleDay == "2026-06-21")
    competitions[0]["status"] = ["displayClock": "0:10", "period": 4, "type": ["name": "STATUS_POSTPONED", "detail": "telemetry"]]
    var competitors = competitions[0]["competitors"] as! [[String: Any]]
    competitors[0]["score"] = "123"; competitors[0]["records"] = [["summary": "10-1"]]
    competitions[0]["competitors"] = competitors
    events[0]["competitions"] = competitions; root["events"] = events
    let games = try FeedDecoder.espn(wnbaData(root), guide: .wnba)
    #expect(games[0].notice == "Postponed")
    var snapshot = ScheduleSnapshot(games: games, day: "2026-06-21", timeZone: wnbaZone.identifier, source: "ESPN · WNBA", limitedCoverage: true)
    snapshot.guide = .wnba
    let data = try JSONEncoder().encode(snapshot), text = String(data: data, encoding: .utf8)!.lowercased()
    for excluded in ["score", "clock", "period", "records", "telemetry", "123"] { #expect(!text.contains(excluded)) }
    #expect(try JSONDecoder().decode(ScheduleSnapshot.self, from: data) == snapshot)
}

private final class WNBAProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            guard request.url!.path.contains("basketball/wnba/") else { throw FeedError.invalid }
            let mode = request.value(forHTTPHeaderField: "X-Tipoff-Test") ?? "valid"
            var root = try wnbaRoot()
            let day = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.queryItems!.first { $0.name == "dates" }!.value!
            if mode == "wrong-league" { root["leagues"] = [["abbreviation": "NBA"]] }
            else if mode == "schema" { root["events"] = "new format" }
            else if mode != "wrong-date" {
                if day == "20260622" {
                    var event = (root["events"] as! [[String: Any]])[0]
                    var comps = event["competitions"] as! [[String: Any]]
                    comps[0]["date"] = "2026-06-22T05:30Z"; event["date"] = "2026-06-22T05:30Z"
                    event["id"] = "late"; event["competitions"] = comps; root["events"] = [event, event]
                } else if day != "20260621" { root["events"] = [] }
            }
            let status = mode == "http" ? 503 : 200
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: try wnbaData(root))
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}
private func wnbaProvider(_ mode: String = "valid") -> ScheduleProvider {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [WNBAProtocol.self]; config.httpAdditionalHeaders = ["X-Tipoff-Test": mode]
    return ScheduleProvider(session: URLSession(configuration: config))
}

@Test func wnbaProviderCombinesAdjacentSourceDaysAndDeduplicates() async throws {
    let day = Dates.parse("2026-06-21T18:00:00Z")!
    let value = try await wnbaProvider().load(day: day, timeZone: wnbaZone, guide: .wnba)
    #expect(value.games.count == 4)
    #expect(value.games.last?.id == "wnba-espn-late")
    #expect(value.games.last?.timeLabel(timeZone: wnbaZone) == "11:30 PM")
    #expect(value.selectedGuide == .wnba && value.limitedCoverage)
    #expect(value.source == "ESPN · WNBA" && value.altitudeWarning == nil)
    #expect(value.displayGames == value.games)
}

@Test @MainActor func wnbaFailuresPreserveOriginalCacheAndFreshness() async throws {
    for mode in ["http", "schema", "wrong-league", "wrong-date"] {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = ScheduleCache(directory: directory)
        var saved = ScheduleSnapshot(games: try FeedDecoder.espn(wnbaData(wnbaRoot()), guide: .wnba), fetchedAt: Dates.parse("2026-06-21T18:00:00Z")!,
            day: Dates.key(Date(), timeZone: wnbaZone), timeZone: wnbaZone.identifier, source: "ESPN · WNBA", limitedCoverage: true)
        saved.guide = .wnba; try cache.write(saved)
        let store = ScheduleStore(provider: wnbaProvider(mode), cache: cache, timeZone: wnbaZone, guide: .wnba)
        store.refresh()
        for _ in 0..<300 { if !store.refreshing { break }; try await Task.sleep(for: .milliseconds(10)) }
        #expect(!store.refreshing && store.isCached && store.error != nil)
        #expect(store.snapshot == saved)
        #expect(cache.read(day: saved.day, timeZone: saved.timeZone, guide: .wnba) == saved)
        #expect(cache.read(day: saved.day, timeZone: saved.timeZone) == nil)
        #expect(cache.read(day: saved.day, timeZone: saved.timeZone, guide: .nfl) == nil)
    }
}
