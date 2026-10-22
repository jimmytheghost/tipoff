import AppKit
import SwiftUI
import TipoffCore

@main struct Check {
    @MainActor static func main() async throws {
        if CommandLine.arguments.contains("--render") {
            _ = NSApplication.shared
            let path = CommandLine.arguments.last!
            let data = try Data(contentsOf: URL(fileURLWithPath: path + ".json"))
            let snapshot = try JSONDecoder().decode(ScheduleSnapshot.self, from: data)
            let store = ScheduleStore(timeZone: TimeZone(identifier: snapshot.timeZone)!, previewSnapshot: snapshot)
            let light = CommandLine.arguments.contains("--light")
            let content: AnyView
            if CommandLine.arguments.contains("--altitude-details"), let game = snapshot.games.first(where: { $0.altitude != nil }) {
                content = AnyView(AltitudeDetailsView(game: game, timeZone: store.timeZone))
            } else { content = AnyView(TipoffMenuView(store: store)) }
            let view = content.environment(\.colorScheme, light ? .light : .dark)
            let hosting = NSHostingView(rootView: view)
            hosting.appearance = NSAppearance(named: light ? .aqua : .darkAqua)
            hosting.frame = NSRect(origin: .zero, size: hosting.fittingSize)
            let window = NSWindow(contentRect: hosting.bounds, styleMask: .borderless, backing: .buffered, defer: false)
            window.contentView = hosting
            // Allow measured list sizing to settle before capturing the popover.
            for _ in 0..<4 {
                hosting.layoutSubtreeIfNeeded()
                try await Task.sleep(for: .milliseconds(20))
                window.setContentSize(hosting.fittingSize)
            }
            hosting.layoutSubtreeIfNeeded()
            guard let bitmap = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { throw FeedError.invalid }
            hosting.cacheDisplay(in: hosting.bounds, to: bitmap)
            guard let png = bitmap.representation(using: .png, properties: [:]) else { throw FeedError.invalid }
            try png.write(to: URL(fileURLWithPath: path))
            print("Rendered \(path)")
            return
        }
        let zone = TimeZone(identifier: "America/Denver")!
        let f = DateFormatter(); f.timeZone = zone; f.dateFormat = "yyyy-MM-dd"
        let date = CommandLine.arguments.dropFirst().first(where: { !$0.hasPrefix("--") }).flatMap { f.date(from: $0) } ?? Date()
        let guide = ScheduleGuide.allCases.first { CommandLine.arguments.contains("--" + $0.rawValue) } ?? .nba
        let snapshot = try await ScheduleProvider().load(day: date, timeZone: zone, guide: guide)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(snapshot)
        try data.write(to: URL(fileURLWithPath: "/tmp/tipoff-preview.png.json"))
        print("\(snapshot.source) | \(snapshot.day) | \(snapshot.games.count) games | limited: \(snapshot.limitedCoverage)")
        if let warning = snapshot.altitudeWarning { print("Warning: \(warning)") }
        for game in snapshot.displayGames {
            print("\(game.scheduleDay) · \(game.away) @ \(game.home) · \(game.timeLabel(timeZone: zone))")
            for broadcast in game.broadcasts { print("  \(broadcast.category): \(broadcast.name)") }
        }
    }
}
