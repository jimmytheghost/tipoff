import Foundation
import TipoffCore

private struct WebSchedule: Encodable {
    let snapshot: ScheduleSnapshot?
    let saved: Bool

    static func write(arguments: [String]) async throws {
        guard arguments.count == 4,
              let guide = ScheduleGuide(rawValue: arguments[0]),
              let zone = TimeZone(identifier: arguments[2]) else { throw FeedError.invalid }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = zone
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: arguments[1]),
              formatter.string(from: date) == arguments[1] else { throw FeedError.invalid }

        let directory = URL(fileURLWithPath: arguments[3], isDirectory: true)
        let cache = ScheduleCache(directory: directory.appendingPathComponent(guide.rawValue))
        let previous = cache.read(day: arguments[1], timeZone: zone.identifier, guide: guide)
        let result: WebSchedule
        if let previous, Date().timeIntervalSince(previous.fetchedAt) < 300 {
            result = WebSchedule(snapshot: previous, saved: false)
        } else {
            let altitude = AltitudeProvider(cacheURL: directory.appendingPathComponent("altitude.json"))
            do {
                let fresh = try await ScheduleProvider(altitude: altitude).load(day: date, timeZone: zone, guide: guide)
                try? cache.write(fresh)
                result = WebSchedule(snapshot: fresh, saved: false)
            } catch {
                result = WebSchedule(snapshot: previous, saved: previous != nil)
            }
        }
        let orderedResult = WebSchedule(snapshot: result.snapshot.map { snapshot in
            var ordered = snapshot
            ordered.games = snapshot.displayGames
            return ordered
        }, saved: result.saved)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        FileHandle.standardOutput.write(try encoder.encode(orderedResult))
    }
}

func writeWebSchedule(arguments: [String]) async throws {
    try await WebSchedule.write(arguments: arguments)
}
