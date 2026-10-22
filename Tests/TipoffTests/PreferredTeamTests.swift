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
