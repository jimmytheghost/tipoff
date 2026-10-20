import AppKit
import Combine
import Foundation

@MainActor public final class ScheduleStore: ObservableObject {
    @Published public private(set) var snapshot: ScheduleSnapshot?
    @Published public private(set) var selectedDate: Date
    @Published public private(set) var refreshing = false
    @Published public private(set) var error: String?
    @Published public private(set) var cacheWarning: String?
    @Published public private(set) var isCached = false
    @Published public private(set) var timeZone: TimeZone
    private let provider: any ScheduleLoading
    private let cache: ScheduleCache
    private var request: Task<Void, Never>?
    private var generation = UUID()
    private var observations: [NSObjectProtocol] = []
    private var followsToday = true
    private var timer: Timer?
    private let preview: Bool
    public var calendar: Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = timeZone; return c }
    public var isToday: Bool { calendar.isDateInToday(selectedDate) }
    public var dateTitle: String {
        if isToday { return "Today" }
        let f = DateFormatter(); f.timeZone = timeZone; f.dateFormat = "EEE, MMM d"
        return f.string(from: selectedDate)
    }
    public init(provider: any ScheduleLoading = ScheduleProvider(), cache: ScheduleCache = ScheduleCache(),
                timeZone: TimeZone = .autoupdatingCurrent, previewSnapshot: ScheduleSnapshot? = nil) {
        self.provider = provider; self.cache = cache; self.timeZone = timeZone
        preview = previewSnapshot != nil
        snapshot = previewSnapshot
        if let previewSnapshot { selectedDate = previewSnapshot.games.first?.start ?? Date() }
        else { selectedDate = Date() }
        guard !preview else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.opened() }
        }
        observations.append(NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.opened() }
        })
        for name in [Notification.Name.NSSystemTimeZoneDidChange, .NSCalendarDayChanged] {
            observations.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.opened() }
            })
        }
    }
    deinit {
        request?.cancel()
        timer?.invalidate()
        for observation in observations {
            NotificationCenter.default.removeObserver(observation)
            NSWorkspace.shared.notificationCenter.removeObserver(observation)
        }
    }
    public func moveDay(_ offset: Int) {
        selectedDate = calendar.date(byAdding: .day, value: offset, to: selectedDate)!
        followsToday = isToday
        refresh()
    }
    public func today() { selectedDate = Date(); followsToday = true; refresh() }
    public func opened() {
        guard !preview else { return }
        timeZone = .autoupdatingCurrent
        if followsToday { selectedDate = Date() }
        refresh()
    }
    public func refresh() {
        guard !preview else { return }
        request?.cancel()
        let token = UUID(); generation = token
        let day = selectedDate, zone = timeZone
        let dayKey = Dates.key(day, timeZone: zone)
        if snapshot?.day != dayKey || snapshot?.timeZone != zone.identifier {
            snapshot = cache.read(day: dayKey, timeZone: zone.identifier)
            isCached = snapshot != nil
        }
        refreshing = true; error = nil; cacheWarning = nil
        request = Task { [weak self, provider, cache] in
            do {
                let result = try await provider.load(day: day, timeZone: zone)
                guard !Task.isCancelled, let self, self.generation == token else { return }
                self.snapshot = result; self.isCached = false; self.refreshing = false
                do { try cache.write(result) }
                catch { self.cacheWarning = "Couldn’t save an offline copy." }
            } catch {
                guard !Task.isCancelled, let self, self.generation == token else { return }
                self.refreshing = false; self.isCached = self.snapshot != nil
                self.error = self.snapshot == nil ? "Couldn’t load games. Check your connection and try again." : "Refresh failed. Showing saved listings."
            }
        }
    }
}
