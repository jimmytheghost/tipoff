import AppKit
import ServiceManagement
import SwiftUI

public struct TipoffMenuView: View {
    @ObservedObject private var store: ScheduleStore
    @State private var showingSettings = false
    @State private var gameListHeight: CGFloat?
    @State private var loginEnabled = SMAppService.mainApp.status == .enabled
    @State private var loginError: String?
    public init(store: ScheduleStore) { self.store = store }
    public var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if showingSettings { settings } else { schedule }
            Divider()
            footer
        }
        .frame(width: 360)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(nsColor: .windowBackgroundColor))
        .tint(.mint)
    }
    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: store.guide.symbol)
                .font(.system(size: 18, weight: .semibold)).foregroundStyle(.mint)
                .frame(width: 30, height: 30)
                .background(.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            Text("Tipoff").font(.headline)
            Spacer()
            Button { showingSettings.toggle() } label: {
                Image(systemName: showingSettings ? "xmark" : "gearshape")
                    .foregroundStyle(showingSettings ? Color.mint : .secondary)
                    .frame(width: 26, height: 28).contentShape(Rectangle())
            }.buttonStyle(.plain)
                .help(showingSettings ? "Back to games" : "Settings")
                .accessibilityLabel(showingSettings ? "Back to games" : "Settings")
        }.padding(14)
    }
    private var schedule: some View {
        VStack(spacing: 12) {
            Picker("Viewing guide", selection: Binding(get: { store.guide }, set: { store.selectGuide($0) })) {
                ForEach(ScheduleGuide.allCases, id: \.self) { Text($0.title).tag($0) }
            }.pickerStyle(.segmented).labelsHidden()
            HStack(spacing: 8) {
                Button { store.moveDay(-1) } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 28, height: 28).contentShape(Rectangle())
                }
                    .help("Previous day").accessibilityLabel("Previous day")
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.dateTitle).font(.subheadline.weight(.semibold))
                    Text(dateSubtitle).font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 2)
                if store.guide == .nfl {
                    if !store.isSunday {
                        Button("Sunday") { store.sunday() }.font(.caption)
                            .help("Show the upcoming Sunday’s NFL games")
                    }
                } else if !store.isToday { Button("Today") { store.today() }.font(.caption) }
                Button { store.moveDay(1) } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 28, height: 28).contentShape(Rectangle())
                }
                    .help("Next day").accessibilityLabel("Next day")
            }.buttonStyle(.plain)
            if let error = store.error {
                message(error, symbol: "wifi.exclamationmark", color: .orange)
            }
            if store.snapshot?.limitedCoverage == true {
                message(store.snapshot?.source.hasPrefix("ESPN") == true ? "Using ESPN. Local and streaming listings may be incomplete." : "TV listings may omit streaming options. Check the broadcaster’s schedule.", symbol: "info.circle", color: .secondary)
            }
            if let warning = store.snapshot?.altitudeWarning {
                message(warning, symbol: "info.circle", color: .orange)
            }
            if let snapshot = store.snapshot {
                if snapshot.games.isEmpty {
                    empty("No \(store.guide.title) games scheduled", detail: "Check the next day’s lineup.", symbol: "moon.stars")
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(snapshot.displayGames) { game in GameRow(game: game, timeZone: store.timeZone) }
                        }
                        .padding(.vertical, 1)
                        .fixedSize(horizontal: false, vertical: true)
                        .onGeometryChange(for: CGFloat.self) { geometry in
                            geometry.size.height
                        } action: { height in
                            if height > 0 { gameListHeight = height }
                        }
                    }
                    .frame(height: min(max(gameListHeight ?? CGFloat(snapshot.games.count) * 76, 60), 450))
                }
            } else if store.refreshing {
                empty("Finding the lineup", detail: "Checking the latest broadcast listings…", symbol: store.guide.symbol)
            } else {
                empty("Schedule unavailable", detail: "Use Refresh to try again.", symbol: "antenna.radiowaves.left.and.right.slash")
            }
        }.padding(14)
    }
    private var dateSubtitle: String {
        let f = DateFormatter(); f.timeZone = store.timeZone; f.dateFormat = "MMM d"
        let zone = store.timeZone.abbreviation(for: store.selectedDate) ?? store.timeZone.identifier
        let count = store.snapshot.map { " · \($0.games.count) \($0.games.count == 1 ? "game" : "games")" } ?? ""
        return "\(f.string(from: store.selectedDate)) · \(zone)\(count)"
    }
    private func empty(_ title: String, detail: String, symbol: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: symbol).font(.system(size: 25)).foregroundStyle(.mint)
            Text(title).font(.subheadline.weight(.medium))
            Text(detail).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(.vertical, 30)
    }
    private func message(_ text: String, symbol: String, color: Color) -> some View {
        Label(text, systemImage: symbol).font(.caption).foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading).fixedSize(horizontal: false, vertical: true)
    }
    private var settings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SETTINGS").font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
            Toggle("Launch at login", isOn: Binding(get: { loginEnabled }, set: { value in
                do {
                    if value { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
                    loginEnabled = SMAppService.mainApp.status == .enabled
                    loginError = SMAppService.mainApp.status == .requiresApproval ? "Approve Tipoff in System Settings → General → Login Items." : nil
                } catch { loginEnabled = SMAppService.mainApp.status == .enabled; loginError = error.localizedDescription }
            })).font(.callout)
            if let loginError { Text(loginError).font(.caption).foregroundStyle(.orange) }
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("Local time, automatically").font(.callout.weight(.medium))
                Text(store.timeZone.identifier).font(.caption).foregroundStyle(.secondary)
                Text("Times follow your Mac and adjust for daylight saving time.").font(.caption).foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Broadcast listings").font(.callout.weight(.medium))
                Text("NBA uses NBA.com with ESPN fallback and the Nuggets’ Altitude supplement. National TV/streaming listings appear first in NBA, with Nuggets first within each group. NFL and WNBA use ESPN. NHL and MLB use league schedules with ESPN fallback. Broncos, Avalanche, and Rockies games lead their guides. Tipoff checks on opening, after wake, and every five minutes.")
                Text("Listings reflect what the source provides. Local rights, subscriptions, and League Pass blackouts still affect availability.")
            }.font(.caption).foregroundStyle(.secondary)
            Link("Open NBA schedule", destination: URL(string: "https://www.nba.com/schedule")!).font(.caption)
            Link("Open NHL schedule", destination: URL(string: "https://www.nhl.com/schedule")!).font(.caption)
            Link("Open MLB schedule", destination: URL(string: "https://www.mlb.com/schedule")!).font(.caption)
            Link("Open WNBA schedule", destination: URL(string: "https://www.wnba.com/schedule")!).font(.caption)
            Link("Open Broncos schedule", destination: URL(string: "https://www.denverbroncos.com/schedule/")!).font(.caption)
        }.padding(14)
        .onAppear { loginEnabled = SMAppService.mainApp.status == .enabled }
    }
    private var footer: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                if let snapshot = store.snapshot {
                    Text(snapshot.source).font(.caption2.weight(.medium))
                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        Text(freshness(snapshot, now: context.date)).font(.caption2).foregroundStyle(store.isCached || context.date.timeIntervalSince(snapshot.fetchedAt) > 600 ? .orange : .secondary)
                    }
                } else { Text("\(store.guide.title) broadcast listings").font(.caption2).foregroundStyle(.secondary) }
                if let warning = store.cacheWarning { Text(warning).font(.caption2).foregroundStyle(.orange) }
            }
            Spacer(minLength: 0)
            if store.refreshing { ProgressView().controlSize(.small).frame(width: 16) }
            Button { store.refresh() } label: { Image(systemName: "arrow.clockwise") }
                .buttonStyle(.plain).disabled(store.refreshing).help("Refresh schedule").accessibilityLabel("Refresh schedule")
            Button("Quit") { NSApplication.shared.terminate(nil) }.buttonStyle(.plain).font(.caption).foregroundStyle(.secondary)
        }.padding(.horizontal, 14).padding(.vertical, 11)
    }
    private func freshness(_ snapshot: ScheduleSnapshot, now: Date) -> String {
        let age = max(0, Int(now.timeIntervalSince(snapshot.fetchedAt) / 60))
        let prefix = store.isCached ? "Saved" : "Checked"
        if age < 1 { return "\(prefix) just now" }
        if age < 60 { return "\(prefix) \(age)m ago" }
        if age < 1440 { return "\(prefix) \(age / 60)h ago" }
        return "\(prefix) \(age / 1440)d ago"
    }
}

private struct GameRow: View {
    let game: Game
    let timeZone: TimeZone
    @State private var showingAltitude = false
    private var video: [Broadcast] { game.broadcasts.filter { !$0.category.lowercased().contains("radio") } }
    private var categories: [String] { var seen = Set<String>(); return video.map(\.category).filter { seen.insert($0).inserted } }
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                if let label = game.preferredTeamLabel {
                    Text(label).font(.system(size: 9, weight: .semibold)).foregroundStyle(.mint)
                }
                team(game.away, home: false)
                team(game.home, home: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(game.timeLabel(timeZone: timeZone))
                    .font(.caption.weight(.semibold)).monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
                if let notice = game.notice {
                    Text(notice).font(.caption2).foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: 64, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                if video.isEmpty {
                    Text("Not listed").font(.caption).foregroundStyle(.secondary)
                } else {
                    ForEach(categories, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(category.uppercased())
                                .font(.system(size: 9, weight: .semibold)).foregroundStyle(.secondary)
                            ForEach(video.filter { $0.category == category }) { broadcast in
                                Text(broadcast.name).font(.caption.weight(.semibold)).foregroundStyle(.mint)
                            }
                        }
                    }
                }
                if game.altitude != nil {
                    Button { showingAltitude.toggle() } label: {
                        Label(game.altitude?.notes.isEmpty == false ? "Details*" : "Details", systemImage: "info.circle").font(.caption2)
                    }
                    .buttonStyle(.plain).foregroundStyle(.secondary)
                    .help("Altitude broadcast times and regional notes")
                    .accessibilityLabel("Altitude broadcast details for \(game.away) at \(game.home)")
                    .popover(isPresented: $showingAltitude) {
                        AltitudeDetailsView(game: game, timeZone: timeZone)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: 92, alignment: .leading)
        }
        .frame(minHeight: 48)
        .padding(10)
        .background(Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke((game.preferredTeamLabel != nil ? Color.mint.opacity(0.45) : Color.primary.opacity(0.055)), lineWidth: 1))
    }
    private func team(_ name: String, home: Bool) -> some View {
        Text(home ? "@ \(name)" : name)
            .font(.callout.weight(.medium))
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("\(home ? "HOME" : "AWAY"): \(name)")
    }
}

public struct AltitudeDetailsView: View {
    let game: Game
    let timeZone: TimeZone
    public init(game: Game, timeZone: TimeZone) { self.game = game; self.timeZone = timeZone }
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nuggets broadcast details").font(.headline)
            Text("\(game.away) @ \(game.home)").font(.caption).foregroundStyle(.secondary)
            if let details = game.altitude {
                VStack(alignment: .leading, spacing: 5) {
                    Text("ALTITUDE’S LISTINGS").font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                    Text(details.networks.isEmpty ? "No networks listed" : details.networks.joined(separator: " / "))
                        .font(.callout.weight(.medium)).foregroundStyle(.mint)
                }
                VStack(spacing: 6) {
                    time("Pregame", details.pregame)
                    time("Game", game.start)
                    time("Postgame", details.postgame)
                }.font(.caption)
                ForEach(details.notes, id: \.self) { note in
                    Text(note).font(.caption).foregroundStyle(.secondary)
                }
                Divider()
                Text("\(details.saved ? "Saved Altitude listings" : "Altitude checked") · \(timestamp(details.fetchedAt, includeYear: true))")
                    .font(.caption2).foregroundStyle(details.saved ? .orange : .secondary)
                Link("Open Altitude schedule", destination: AltitudeDecoder.sourceURL).font(.caption)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: 280, alignment: .leading)
        .padding(14)
        .background(Color(nsColor: .windowBackgroundColor))
        .tint(.mint)
    }
    private func timestamp(_ date: Date, includeYear: Bool = false) -> String {
        let f = DateFormatter(); f.timeZone = timeZone
        f.dateFormat = includeYear ? "MMM d, yyyy h:mm a z" : "MMM d, h:mm a z"
        return f.string(from: date)
    }
    private func time(_ title: String, _ date: Date?) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(date.map { timestamp($0) } ?? "Not listed").monospacedDigit()
        }
    }
}
