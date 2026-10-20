import Foundation

public struct AltitudeEntry: Codable, Equatable, Sendable {
    public var day: String
    public var opponentCode: String
    public var denverHome: Bool
    public var start: Date
    public var pregame: Date?
    public var postgame: Date?
    public var networks: [String]
    public var notes: [String]
}

public struct AltitudeSchedule: Codable, Sendable {
    public var entries: [AltitudeEntry]
    public var fetchedAt: Date
}

public struct AltitudeDetails: Codable, Equatable, Sendable {
    public var pregame: Date?
    public var postgame: Date?
    public var networks: [String]
    public var notes: [String]
    public var fetchedAt: Date
    public var saved: Bool
}

public enum AltitudeDecoder {
    public static let sourceURL = URL(string: "https://www.altitudeplus.com/nuggets-broadcasts")!
    private static let mountain = TimeZone(identifier: "America/Denver")!
    private static let opponents = [
        "Atlanta Hawks": "ATL", "Boston Celtics": "BOS", "Brooklyn Nets": "BKN", "Charlotte Hornets": "CHA",
        "Chicago Bulls": "CHI", "Cleveland Cavaliers": "CLE", "Dallas Mavericks": "DAL", "Detroit Pistons": "DET",
        "Golden State Warriors": "GSW", "Houston Rockets": "HOU", "Indiana Pacers": "IND", "Los Angeles Clippers": "LAC",
        "LA Clippers": "LAC", "Los Angeles Lakers": "LAL", "Memphis Grizzlies": "MEM", "Miami Heat": "MIA",
        "Milwaukee Bucks": "MIL", "Minnesota Timberwolves": "MIN", "New Orleans Pelicans": "NOP", "New York Knicks": "NYK",
        "Oklahoma City Thunder": "OKC", "Orlando Magic": "ORL", "Philadelphia 76ers": "PHI", "Phoenix Suns": "PHX",
        "Portland Trail Blazers": "POR", "Sacramento Kings": "SAC", "San Antonio Spurs": "SAS", "Toronto Raptors": "TOR",
        "Utah Jazz": "UTA", "Washington Wizards": "WAS"
    ]
    private static func captures(_ pattern: String, in string: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else { return [] }
        return regex.matches(in: string, range: NSRange(string.startIndex..., in: string)).compactMap {
            Range($0.range(at: 1), in: string).map { String(string[$0]) }
        }
    }
    private static func text(_ html: String) -> String {
        var value = html.replacingOccurrences(of: "<[^>]*>", with: " ", options: .regularExpression)
        for (entity, replacement) in [("&amp;", "&"), ("&nbsp;", " "), ("&#39;", "'"), ("&quot;", "\""), ("&#x27;", "'")] {
            value = value.replacingOccurrences(of: entity, with: replacement)
        }
        return value.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    // Extract JSON, never execute the page's JavaScript or persist its visitor/configuration data.
    public static func page(_ data: Data, fetchedAt: Date = Date()) throws -> AltitudeSchedule {
        guard let html = String(data: data, encoding: .utf8),
              let assignment = html.range(of: #"window\.page_data\s*=\s*"#, options: .regularExpression) else { throw FeedError.invalid }
        let suffix = html[assignment.upperBound...]
        var depth = 0, inString = false, escaped = false
        var end: String.Index?
        for index in suffix.indices {
            let c = suffix[index]
            if inString {
                if escaped { escaped = false }
                else if c == "\\" { escaped = true }
                else if c == "\"" { inString = false }
            } else if c == "\"" { inString = true }
            else if c == "{" { depth += 1 }
            else if c == "}" { depth -= 1; if depth == 0 { end = suffix.index(after: index); break } }
        }
        guard let end, let json = String(suffix[..<end]).data(using: .utf8),
              let root = try JSONSerialization.jsonObject(with: json) as? [String: Any],
              root["path"] as? String == "/nuggets-broadcasts",
              let page = root["page"] as? [String: Any],
              let modules = page["modules"] as? [[String: Any]] else { throw FeedError.invalid }
        let tables = modules.compactMap { $0["rawText"] as? String }.filter { $0.contains("<table") }
        guard !tables.isEmpty else { throw FeedError.invalid }
        return AltitudeSchedule(entries: try table(tables.joined(separator: "\n")), fetchedAt: fetchedAt)
    }
    public static func table(_ html: String) throws -> [AltitudeEntry] {
        let rows = captures(#"<tr\b[^>]*>(.*?)</tr>"#, in: html)
        let expected = ["date", "matchup", "home/away", "pregame", "game start", "postgame", "networks"]
        let notes = captures(#"<p\b[^>]*>(.*?)</p>"#, in: html).map(text).filter { $0.hasPrefix("*") || $0.hasPrefix("^") }
        var entries: [AltitudeEntry] = []
        var foundHeader = false
        let date = DateFormatter(); date.locale = Locale(identifier: "en_US_POSIX"); date.timeZone = mountain
        date.dateFormat = "M/d/yyyy"; date.isLenient = false
        let clock = DateFormatter(); clock.locale = Locale(identifier: "en_US_POSIX"); clock.timeZone = mountain
        clock.dateFormat = "M/d/yyyy h:mm a"; clock.isLenient = false
        for row in rows {
            if row.range(of: "<th\\b", options: [.regularExpression, .caseInsensitive]) != nil {
                guard captures(#"<th\b[^>]*>(.*?)</th>"#, in: row).map({ text($0).lowercased() }) == expected else { throw FeedError.invalid }
                foundHeader = true; continue
            }
            let cells = captures(#"<td\b[^>]*>(.*?)</td>"#, in: row).map(text)
            guard foundHeader, cells.count == 7 else { throw FeedError.invalid }
            if cells.allSatisfy({ $0.uppercased() == "TBD" }) { continue }
            guard let day = date.date(from: cells[0]), let start = clock.date(from: cells[0] + " " + cells[4]),
                  ["Home", "Away"].contains(cells[2]) else { throw FeedError.invalid }
            let matchup = cells[1].replacingOccurrences(of: #"\s*\([^)]*\)"#, with: "", options: .regularExpression)
                .replacingOccurrences(of: "Pre Season: ", with: "")
            let candidates = opponents.filter { matchup.contains($0.key) }
            // Require one known opponent and an explicit Nuggets matchup, including neutral-site "vs" rows.
            guard matchup.contains("Nuggets"), Set(candidates.values).count == 1, let code = candidates.first?.value else { throw FeedError.invalid }
            func showTime(_ value: String, postgame: Bool = false) throws -> Date? {
                if ["", "n/a", "tbd"].contains(value.lowercased()) { return nil }
                guard var result = clock.date(from: cells[0] + " " + value) else { throw FeedError.invalid }
                // Overnight postgame shows belong to the following Mountain calendar day.
                if postgame, result < start {
                    var calendar = Calendar(identifier: .gregorian); calendar.timeZone = mountain
                    result = calendar.date(byAdding: .day, value: 1, to: result)!
                }
                return result
            }
            let networks = cells[6].lowercased() == "none" ? [] : cells[6].components(separatedBy: CharacterSet(charactersIn: "/&"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            guard !networks.contains(where: { $0.lowercased() == "tbd" }) else { throw FeedError.invalid }
            for marker in ["*", "^"] where cells[6].contains(marker) {
                guard notes.contains(where: { $0.hasPrefix(marker) }) else { throw FeedError.invalid }
            }
            entries.append(AltitudeEntry(day: Dates.key(day, timeZone: mountain), opponentCode: code,
                denverHome: cells[2] == "Home", start: start, pregame: try showTime(cells[3]), postgame: try showTime(cells[5], postgame: true),
                networks: networks, notes: notes.filter { cells[6].contains(String($0.prefix(1))) }))
        }
        guard foundHeader, !entries.isEmpty else { throw FeedError.invalid }
        return entries
    }
    public static func enrich(_ game: Game, with schedule: AltitudeSchedule, saved: Bool) -> (game: Game, warning: String?) {
        guard game.homeCode == "DEN" || game.awayCode == "DEN" else { return (game, nil) }
        guard game.notice == nil else {
            return (game, "Altitude’s listings weren’t applied to the changed Nuggets game schedule.")
        }
        let day = game.start.map { Dates.key($0, timeZone: mountain) } ?? game.scheduleDay
        let matches = schedule.entries.filter { $0.day == day && $0.denverHome == (game.homeCode == "DEN") && $0.opponentCode == (game.homeCode == "DEN" ? game.awayCode : game.homeCode) }
        guard matches.count == 1, let entry = matches.first else {
            return (game, "No matching Nuggets listing on Altitude’s schedule.")
        }
        guard let start = game.start, abs(start.timeIntervalSince(entry.start)) < 60 else {
            return (game, "Altitude’s tipoff differs from the game schedule; its listings weren’t applied.")
        }
        var game = game
        let names = ["ALT": "Altitude", "ALT2": "Altitude 2", "Prime": "Prime Video"]
        func canonical(_ name: String) -> String {
            let clean = name.trimmingCharacters(in: CharacterSet(charactersIn: "*^"))
            return names[clean] ?? clean
        }
        var existing = Set(game.broadcasts.map { canonical($0.name).lowercased() })
        let additions = entry.networks.filter { existing.insert(canonical($0).lowercased()).inserted }
        game.broadcasts = additions.map { Broadcast(name: canonical($0) + ($0.hasSuffix("*") ? "*" : $0.hasSuffix("^") ? "^" : ""), category: "Altitude guide") } + game.broadcasts
        game.altitude = AltitudeDetails(pregame: entry.pregame, postgame: entry.postgame, networks: entry.networks,
            notes: entry.notes, fetchedAt: schedule.fetchedAt, saved: saved)
        return (game, nil)
    }
}

public actor AltitudeProvider {
    private let session: URLSession
    private let cacheURL: URL
    public init(session: URLSession = .shared, cacheURL: URL? = nil) {
        self.session = session
        self.cacheURL = cacheURL ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Tipoff/Altitude.json")
    }
    public func load() async throws -> (schedule: AltitudeSchedule?, warning: String?, saved: Bool) {
        do {
            var request = URLRequest(url: AltitudeDecoder.sourceURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 12)
            request.setValue("Mozilla/5.0 Tipoff/0.2", forHTTPHeaderField: "User-Agent")
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw FeedError.unavailable }
            let schedule = try AltitudeDecoder.page(data)
            try Task.checkCancellation()
            do {
                try FileManager.default.createDirectory(at: cacheURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try JSONEncoder().encode(schedule).write(to: cacheURL, options: .atomic)
                return (schedule, nil, false)
            } catch { return (schedule, "Couldn’t save Altitude’s offline listings.", false) }
        } catch {
            try Task.checkCancellation()
            if let data = try? Data(contentsOf: cacheURL), let saved = try? JSONDecoder().decode(AltitudeSchedule.self, from: data) {
                return (saved, "Altitude refresh failed. Showing saved Altitude listings; check Details for their age.", true)
            }
            return (nil, "Couldn’t check Altitude’s Nuggets listings. Other listings are still shown.", false)
        }
    }
}
