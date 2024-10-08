//
//  ActivityViewModel.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 26.01.2023.
//

import Foundation

actor EventLogger {
    private var events = [ActivityEvent]()

    func checkIfHasUnseenEvents() -> Bool {
        if events.filter({$0.seen == false}).count != 0 {
            return true
        } else {
            return false
        }
    }

    func setEvents(_ events: [ActivityEvent]) {
        self.events = events
    }
}

@MainActor
class ActivityViewModel {

    let service: ActivityServiceProtocol

    private var events = [ActivityEvent]() {
        didSet {
            checkIfHasUnseenEvents()
        }
    }

    private var seenEvents = Set<ActivityEvent>()

    var eventsCount: Int {
        return events.count
    }

    var hasUnseenEvents = Observable(false)
    var hasZeroEvents: Bool {
        return events.isEmpty
    }

    init(service: ActivityServiceProtocol) {
        self.service = service
        observeActivityEvents()
    }

    func observeActivityEvents() {
        Task {
            do {
                for try await events in service.observeActivityEvents() {
                    let eventsWithAdditionalData = try await service.getAdditionalDataFor(events: events)
                    self.events = eventsWithAdditionalData.reversed()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func checkIfHasUnseenEvents() {
        if events.filter({$0.seen == false}).count != 0 {
            hasUnseenEvents.value = true
        } else {
            hasUnseenEvents.value = false
        }
    }

    func getEvent(for indexPath: IndexPath) -> ActivityEvent {
        return events[indexPath.row]
    }

    func eventSeenStatus(at indexPath: IndexPath) -> Bool {
        return events[indexPath.row].seen
    }

    func updateActivityEventsSeenStatus() async throws {
        try await service.updateActivityEventsSeenStatus(events: seenEvents)
        self.seenEvents = Set<ActivityEvent>()
    }

    func markEventAsSeen(at indexPath: IndexPath) {
        events[indexPath.row].seen = true
        let seenEvent = events[indexPath.row]
        seenEvents.insert(seenEvent)
    }
}
