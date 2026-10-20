import Foundation

// Read only scheduling and broadcast fields. Scores never enter Tipoff's data model or cache.
public enum FeedDecoder {
    private static func object(_ data: Data) throws -> [String: Any] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw FeedError.invalid }
        return root
    }
    private static func text(_ value: Any?) -> String { value as? String ?? "" }
    private static func notice(_ status: String) -> String? {
        let s = status.lowercased()
        if s.contains("postpon") { return "Postponed" }
        if s.contains("cancel") { return "Cancelled" }
        if s.contains("delay") { return "Delayed" }
        return nil
    }
    private static func unique(_ values: [Broadcast]) -> [Broadcast] {
        var seen = Set<String>()
        return values.filter { !$0.name.isEmpty && seen.insert($0.id).inserted }
    }
    public static func nbaPage(_ data: Data, expectedDay: String) throws -> [Game] {
        guard let html = String(data: data, encoding: .utf8),
              let expression = try? NSRegularExpression(pattern: #"<script\b[^>]*\bid=["']__NEXT_DATA__["'][^>]*>([\s\S]*?)</script>"#),
              let match = expression.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html),
              let json = String(html[range]).data(using: .utf8),
              let props = try object(json)["props"] as? [String: Any],
              let page = props["pageProps"] as? [String: Any],
              page["hasError"] as? Bool != true,
              page["selectedDate"] as? String == expectedDay,
              let feed = page["gameCardFeed"] as? [String: Any],
              feed["nextPageToken"] == nil || feed["nextPageToken"] is NSNull,
              let modules = feed["modules"] as? [[String: Any]] else { throw FeedError.invalid }
        var rows: [[String: Any]] = []
        for module in modules {
            for card in module["cards"] as? [[String: Any]] ?? [] {
                guard var game = card["cardData"] as? [String: Any], game["gameId"] != nil else { continue }
                game["gameDateTimeUTC"] = game["gameTimeUtc"]
                game["gameDateEst"] = expectedDay
                rows.append(game)
            }
        }
        if let years = page["allGamesInCurrentYear"] as? [String: [String: Int]],
           let count = years[String(expectedDay.prefix(4))]?[expectedDay], count > rows.count { throw FeedError.invalid }
        if rows.isEmpty { return [] }
        let normalized: [String: Any] = ["leagueSchedule": ["gameDates": [["games": rows]]]]
        return try nba(JSONSerialization.data(withJSONObject: normalized))
    }
    public static func nba(_ data: Data) throws -> [Game] {
        guard let schedule = try object(data)["leagueSchedule"] as? [String: Any],
              let dates = schedule["gameDates"] as? [[String: Any]], !dates.isEmpty else { throw FeedError.invalid }
        var games: [Game] = []
        for date in dates {
            guard let rows = date["games"] as? [[String: Any]] else { throw FeedError.invalid }
            for row in rows {
                guard let home = row["homeTeam"] as? [String: Any], let away = row["awayTeam"] as? [String: Any],
                      let id = row["gameId"] as? String else { throw FeedError.invalid }
                var broadcasts: [Broadcast] = []
                let groups = row["broadcasters"] as? [String: Any] ?? [:]
                let categories = [
                    ("nationalBroadcasters", "National"), ("nationalTvBroadcasters", "National"), ("nationalOttBroadcasters", "Streaming"),
                    ("homeTvBroadcasters", "Home TV"), ("awayTvBroadcasters", "Away TV"),
                    ("homeOttBroadcasters", "Home streaming"), ("awayOttBroadcasters", "Away streaming"),
                    ("nationalRadioBroadcasters", "National radio"), ("homeRadioBroadcasters", "Home radio"),
                    ("awayRadioBroadcasters", "Away radio"), ("subscriptionBroadcasters", "Subscription")
                ]
                for (key, category) in categories {
                    for b in groups[key] as? [[String: Any]] ?? [] {
                        let name = ["broadcasterDisplay", "broadcasterDisplayName", "broadcasterName"].map { text(b[$0]) }.first { !$0.isEmpty } ?? ""
                        broadcasts.append(Broadcast(name: name, category: category))
                    }
                }
                let status = text(row["gameStatusText"])
                let tbd = status.lowercased().contains("tbd") || status.lowercased().contains("tba") || (row["gameTimeTBD"] as? Bool == true)
                let start = tbd ? nil : Dates.parse(row["gameDateTimeUTC"] as? String)
                let day = String(text(row["gameDateEst"]).prefix(10))
                guard start != nil || day.count == 10 else { throw FeedError.invalid }
                func name(_ team: [String: Any]) -> String {
                    [text(team["teamCity"]), text(team["teamName"])].filter { !$0.isEmpty }.joined(separator: " ")
                }
                games.append(Game(id: "nba-" + id, away: name(away), home: name(home),
                    awayCode: text(away["teamTricode"]), homeCode: text(home["teamTricode"]),
                    start: start, scheduleDay: day, notice: notice(status), broadcasts: unique(broadcasts)))
            }
        }
        guard !games.isEmpty else { throw FeedError.invalid }
        return Dates.sorted(games)
    }
    public static func espn(_ data: Data) throws -> [Game] {
        guard let events = try object(data)["events"] as? [[String: Any]] else { throw FeedError.invalid }
        return try events.map { row in
            guard let id = row["id"] as? String,
                  let competition = (row["competitions"] as? [[String: Any]])?.first,
                  let competitors = competition["competitors"] as? [[String: Any]],
                  let home = competitors.first(where: { text($0["homeAway"]) == "home" })?["team"] as? [String: Any],
                  let away = competitors.first(where: { text($0["homeAway"]) == "away" })?["team"] as? [String: Any],
                  let start = Dates.parse((competition["date"] ?? row["date"]) as? String) else { throw FeedError.invalid }
            let status = (competition["status"] ?? row["status"]) as? [String: Any] ?? [:]
            let type = status["type"] as? [String: Any] ?? [:]
            let statusName = text(type["name"])
            var broadcasts: [Broadcast] = []
            for b in competition["geoBroadcasts"] as? [[String: Any]] ?? [] {
                let region = text(b["region"]).lowercased()
                guard region.isEmpty || region == "us" else { continue }
                let market = b["market"] as? [String: Any] ?? [:]
                let media = b["media"] as? [String: Any] ?? [:]
                let kind = text((b["type"] as? [String: Any])?["shortName"])
                let locale = text(market["type"])
                let category = kind.lowercased() == "radio" ? "\(locale) radio" : (locale.isEmpty ? "TV / streaming" : locale)
                broadcasts.append(Broadcast(name: text(media["shortName"]), category: category))
            }
            // Some events expose only the older broadcast list.
            if broadcasts.isEmpty {
                for b in competition["broadcasts"] as? [[String: Any]] ?? [] {
                    for name in b["names"] as? [String] ?? [] {
                        broadcasts.append(Broadcast(name: name, category: text(b["market"]).capitalized))
                    }
                }
            }
            let tbd = type["name"] as? String == "STATUS_SCHEDULED" && (competition["timeValid"] as? Bool == false)
            return Game(id: "espn-" + id, away: text(away["displayName"]), home: text(home["displayName"]),
                awayCode: text(away["abbreviation"]), homeCode: text(home["abbreviation"]),
                start: tbd ? nil : start, scheduleDay: Dates.key(start, timeZone: TimeZone(identifier: "America/New_York")!),
                notice: notice(statusName), broadcasts: unique(broadcasts))
        }
    }
}
