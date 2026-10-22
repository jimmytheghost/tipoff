import AppKit
import SwiftUI
import TipoffCore

@main struct TipoffApp: App {
    @StateObject private var store = ScheduleStore()
    var body: some Scene {
        MenuBarExtra {
            TipoffMenuView(store: store).onAppear { store.opened() }
        } label: {
            Image(systemName: store.guide.symbol).accessibilityLabel("Tipoff")
        }.menuBarExtraStyle(.window)
    }
}
