import Foundation

// Project only schedule and broadcast fields from the league website responses.
public enum LeagueFeedDecoder {
    private static func root(_ data: Data) throws -> [String: Any] {
        guard let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw FeedError.invalid }
        return value
    }
    private static func required(_ value: Any?) throws -> String {
        guard let text = value as? String, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw FeedError.invalid }
        return text
    }
    private static func unique(_ values: [Broadcast]) -> [Broadcast] {
        var seen = Set<String>()
        return values.filter { seen.insert($0.id).inserted }
    }
    private static func entries(_ value: Any?) throws -> [[String: Any]] {
        guard let value else { return [] } // Missing listings are unknown, not invented.
        guard let rows = value as? [[String: Any]] else { throw FeedError.invalid }
        return rows
    }
    public static func nhl(_ data: Data, expectedDay: String) throws -> [Game] {
        let value = try root(data)
        guard let days = value["gameWeek"] as? [[String: Any]],
              let count = value["numberOfGames"] as? Int else { throw FeedError.invalid }
        var total = 0, selected: [[String: Any]] = []
        var matched = false
        for day in days {
            guard let date = day["date"] as? String, let games = day["games"] as? [[String: Any]] else { throw FeedError.invalid }
            total += games.count
            if date == expectedDay { matched = true; selected += games }
        }
        guard matched, count == total else { throw FeedError.invalid }
        return try selected.map { row in
            guard let id = row["id"] as? Int,
                  let away = row["awayTeam"] as? [String: Any], let home = row["homeTeam"] as? [String: Any],
                  let start = Dates.parse(row["startTimeUTC"] as? String) else { throw FeedError.invalid }
            func name(_ team: [String: Any]) throws -> String {
                let place = try required((team["placeName"] as? [String: Any])?["default"])
                let common = try required((team["commonName"] as? [String: Any])?["default"])
                return place + " " + common
            }
            let state = try required(row["gameScheduleState"])
            guard ["OK", "TBD", "PPD", "CNCL", "SUSP"].contains(state) else { throw FeedError.invalid }
            let broadcasts = try entries(row["tvBroadcasts"]).compactMap { entry -> Broadcast? in
                let country = try required(entry["countryCode"])
                guard country == "US" else { return nil }
                let network = try required(entry["network"])
                let market = try required(entry["market"])
                let category: String
                switch market {
                case "H": category = "Home TV"
                case "A": category = "Away TV"
                case "N": category = "National"
                default: throw FeedError.invalid
                }
                return Broadcast(name: network, category: category)
            }
            let notice: String? = state == "PPD" ? "Postponed" : state == "CNCL" ? "Cancelled" : state == "SUSP" ? "Suspended" : nil
            return try Game(id: "nhl-" + String(id), away: name(away), home: name(home),
                awayCode: required(away["abbrev"]), homeCode: required(home["abbrev"]),
                start: state == "TBD" ? nil : start, scheduleDay: expectedDay, notice: notice, broadcasts: unique(broadcasts))
        }
    }
    public static func mlb(_ data: Data, expectedDay: String) throws -> [Game] {
        let value = try root(data)
        guard let days = value["dates"] as? [[String: Any]], let count = value["totalGames"] as? Int else { throw FeedError.invalid }
        var rows: [[String: Any]] = []
        for day in days {
            guard day["date"] as? String == expectedDay,
                  let games = day["games"] as? [[String: Any]] else { throw FeedError.invalid }
            rows += games
        }
        guard count == rows.count else { throw FeedError.invalid }
        return try rows.map { row in
            guard let id = row["gamePk"] as? Int, let teams = row["teams"] as? [String: Any],
                  let away = (teams["away"] as? [String: Any])?["team"] as? [String: Any],
                  let home = (teams["home"] as? [String: Any])?["team"] as? [String: Any],
                  let awayID = away["id"] as? Int, let homeID = home["id"] as? Int,
                  let start = Dates.parse(row["gameDate"] as? String),
                  let status = row["status"] as? [String: Any], let tbd = status["startTimeTBD"] as? Bool else { throw FeedError.invalid }
            let detail = try required(status["detailedState"]).lowercased()
            var notices: [String] = []
            if let header = row["doubleHeader"] as? String, header != "N" {
                guard ["Y", "S"].contains(header), let number = row["gameNumber"] as? Int, number > 0 else { throw FeedError.invalid }
                notices.append("Game \(number)")
            }
            if detail.contains("postpon") { notices.append("Postponed") }
            else if detail.contains("cancel") { notices.append("Cancelled") }
            else if detail.contains("suspend") { notices.append("Suspended") }
            else if detail.contains("delay") { notices.append("Delayed") }
            let broadcasts = try entries(row["broadcasts"]).compactMap { entry -> Broadcast? in
                let type = try required(entry["type"])
                if ["AM", "FM"].contains(type) { return nil }
                guard type == "TV" else { throw FeedError.invalid } // Unknown types must not erase saved listings.
                let name = try required(entry["name"])
                guard let national = entry["isNational"] as? Bool else { throw FeedError.invalid }
                let side = entry["homeAway"] as? String
                let category: String
                if national { category = "National" }
                else if side == "home" { category = "Home" }
                else if side == "away" { category = "Away" }
                else { throw FeedError.invalid }
                return Broadcast(name: name, category: category)
            }
            return try Game(id: "mlb-" + String(id), away: required(away["name"]), home: required(home["name"]),
                awayCode: String(awayID), homeCode: String(homeID), start: tbd ? nil : start,
                scheduleDay: expectedDay, notice: notices.isEmpty ? nil : notices.joined(separator: " · "), broadcasts: unique(broadcasts))
        }
    }
}
