import Foundation
import Testing
@testable import TipoffCore

@Test func avalancheAndRockiesIdentityIsScopedToTheirSportAndSource() {
    for (prefix, code, label) in [("nhl-", "COL", "AVALANCHE"), ("nhl-espn-", "COL", "AVALANCHE"), ("mlb-", "115", "ROCKIES"), ("mlb-espn-", "COL", "ROCKIES")] {
        for home in [true, false] {
            let game = Game(id: prefix + "1", away: "Away", home: "Home", awayCode: home ? "OTHER" : code,
                homeCode: home ? code : "OTHER", start: nil, scheduleDay: "2026-10-22", broadcasts: [])
            #expect(game.preferredTeamLabel == label)
            #expect(!game.isNuggets && !game.isBroncos)
            #expect(game.isAvalanche == (label == "AVALANCHE"))
            #expect(game.isRockies == (label == "ROCKIES"))
        }
    }
    for prefix in ["nba-", "espn-", "nfl-espn-", "wnba-espn-"] {
        let other = Game(id: prefix + "1", away: "Away", home: "Home", awayCode: "COL", homeCode: "115", start: nil, scheduleDay: "2026-10-22", broadcasts: [])
        #expect(other.preferredTeamLabel == nil)
        #expect(!other.isRockies && !other.isAvalanche)
    }
}

@Test func coloradoTeamsAppearFirstInSavedSchedulesWithOtherGamesChronological() throws {
    for guide: ScheduleGuide in [.nhl, .mlb] {
        for fallback in [true, false] {
            for home in [true, false] {
                let prefix = guide.rawValue + (fallback ? "-espn-" : "-")
                let code = guide == .mlb && !fallback ? "115" : "COL"
                func game(_ id: String, hour: String, preferred: Bool) -> Game {
                    Game(id: prefix + id, away: "Away", home: "Home", awayCode: preferred && !home ? code : "OTHER",
                        homeCode: preferred && home ? code : "OTHER", start: Dates.parse("2026-07-01T\(hour):00:00Z"),
                        scheduleDay: "2026-07-01", broadcasts: [Broadcast(name: "Listed network", category: "National")])
                }
                let early = game("early", hour: "16", preferred: false), late = game("late", hour: "21", preferred: false)
                let first = game("first", hour: "22", preferred: true), second = game("second", hour: "23", preferred: true)
                var snapshot = ScheduleSnapshot(games: [second, late, first, early], fetchedAt: Dates.parse("2026-06-30T12:00:00Z")!,
                    day: "2026-07-01", timeZone: "America/Denver", source: fallback ? "ESPN fallback" : "League source", limitedCoverage: fallback)
                snapshot.guide = guide
                let data = try JSONEncoder().encode(snapshot), saved = try JSONDecoder().decode(ScheduleSnapshot.self, from: data)
                // Multiple preferred events (e.g. a doubleheader) retain their time order.
                #expect(saved.displayGames.map(\.id) == [first.id, second.id, early.id, late.id])
                #expect(saved.games == snapshot.games)
                #expect(saved.fetchedAt == snapshot.fetchedAt && saved.source == snapshot.source && saved.limitedCoverage == snapshot.limitedCoverage)
                #expect(!String(data: data, encoding: .utf8)!.contains("preferredTeam"))
                var empty = snapshot; empty.games = []
                #expect(empty.displayGames.isEmpty)
            }
        }
    }
}

@Test func nbaBroadcastPriorityUsesListingsWithoutInferringLeaguePassAccess() {
    for (name, category) in [("Prime Video", "Streaming"), ("Peacock", "National"), ("ESPN", "national"),
                             ("ABC", "TV / streaming"), ("NBC", "TV / streaming"),
                             ("Amazon Prime Video", "TV / streaming"), ("Future network", "National")] {
        let game = Game(id: "nba-test", away: "Away", home: "Home", awayCode: "A", homeCode: "B",
            start: nil, scheduleDay: "2026-10-23", broadcasts: [Broadcast(name: name, category: category)])
        #expect(game.hasNationalNBABroadcast)
    }
    for (name, category) in [("League Pass", "Subscription"), ("NBA League Pass", "National"),
                             ("NBA TV", "National"), ("NBATV", "Streaming"), ("ESPN Radio", "National radio"),
                             ("Altitude+", "Home streaming"), ("Peacock", "Away streaming"),
                             ("Unknown", "TV / streaming"), ("", "National")] {
        let game = Game(id: "nba-test", away: "Away", home: "Home", awayCode: "A", homeCode: "B",
            start: nil, scheduleDay: "2026-10-23", broadcasts: [Broadcast(name: name, category: category)])
        #expect(!game.hasNationalNBABroadcast)
    }
}

@Test func nbaNationalListingsLeadSavedSchedulesBeforeLeaguePassAndRegionalGames() throws {
    for prefix in ["nba-", "espn-"] {
        func game(_ id: String, hour: String?, nuggets: Bool = false, broadcasts: [Broadcast]) -> Game {
            Game(id: prefix + id, away: "Away", home: "Home", awayCode: "A", homeCode: nuggets ? "DEN" : "B",
                start: hour.flatMap { Dates.parse("2026-10-23T\($0):00:00Z") }, scheduleDay: "2026-10-23", broadcasts: broadcasts)
        }
        let leaguePass = Broadcast(name: "League Pass", category: "Subscription")
        let early = game("early", hour: "16", broadcasts: [leaguePass])
        let denver = game("denver", hour: "22", nuggets: true, broadcasts: [leaguePass, Broadcast(name: "Altitude", category: "Home TV")])
        let prime = game("prime", hour: "20", broadcasts: [Broadcast(name: "Prime Video", category: "Streaming"), leaguePass])
        let peacock = game("peacock", hour: "19", broadcasts: [Broadcast(name: "Peacock", category: "National")])
        let espn = game("espn", hour: "23", broadcasts: [Broadcast(name: "ESPN", category: "TV / streaming")])
        let unknown = game("unknown", hour: nil, broadcasts: [])
        let nbaTV = game("nbaTV", hour: "18", broadcasts: [Broadcast(name: "NBA TV", category: "National")])
        let snapshot = ScheduleSnapshot(games: [unknown, denver, espn, early, prime, nbaTV, peacock],
            fetchedAt: Dates.parse("2026-10-22T12:00:00Z")!, day: "2026-10-23", timeZone: "America/Denver",
            source: prefix == "nba-" ? "NBA.com + Altitude" : "ESPN fallback", limitedCoverage: prefix == "espn-")
        let saved = try JSONDecoder().decode(ScheduleSnapshot.self, from: JSONEncoder().encode(snapshot))
        #expect(saved.displayGames.map(\.id) == [peacock, prime, espn, denver, early, nbaTV, unknown].map(\.id))
        #expect(saved == snapshot)
        var nationalDenver = denver
        nationalDenver.broadcasts.append(Broadcast(name: "NBC", category: "National"))
        var changed = saved
        changed.games = changed.games.map { $0.id == denver.id ? nationalDenver : $0 }
        #expect(changed.displayGames.first == nationalDenver)
        // Other guides do not acquire the NBA broadcast preference.
        var wnba = saved; wnba.guide = .wnba
        #expect(wnba.displayGames == wnba.games)
    }
}
