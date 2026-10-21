import AppKit
import SwiftUI
import TipoffCore

@main struct TipoffApp: App {
    @StateObject private var store = ScheduleStore()
    var body: some Scene {
        MenuBarExtra {
            TipoffMenuView(store: store).onAppear { store.opened() }
        } label: {
            Image(systemName: store.guide == .nba ? "basketball" : "american.football").accessibilityLabel("Tipoff")
        }.menuBarExtraStyle(.window)
    }
}
