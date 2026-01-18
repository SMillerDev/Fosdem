//
//  ListPredicate.swift
//  Fosdem
//
//  Created by Sean Molenaar on 05/02/2023.
//  Copyright © 2023 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftUI

class ListSettings: ObservableObject {
    @Published var onlyFuture: Bool = false
    @Published var deniedTypes: [String] = []
    @Published var deniedRooms: [String] = []
    @Published var deniedTracks: [String] = []

    var isFiltering: Bool {
        onlyFuture || !deniedTypes.isEmpty
    }

    @available(*, deprecated, renamed: "eventPredicate", message: "Should use more specific predicate")
    public func predicate(_ type: ListPredicateType) -> Predicate<Event> {
        return self.eventPredicate()
    }

    public func eventPredicate() -> Predicate<Event> {
        var predicate: Predicate<Event> = #Predicate<Event> { _ in true }

        if onlyFuture {
            let basePredicate = ListSettings.futurePredicate()
            predicate = #Predicate<Event> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        if !deniedTypes.isEmpty {
            let basePredicate = #Predicate<Event> {
                !deniedTypes.contains($0.typeName)
            }
            predicate = #Predicate<Event> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        return predicate
    }

    public func roomPredicate() -> Predicate<Room> {
        var predicate: Predicate<Room> = #Predicate<Room> { _ in true }

        if onlyFuture {
            let now = Date()
            let basePredicate = #Predicate<Room> { room in
                room.events.allSatisfy({ $0.end > now })
            }
            predicate = #Predicate<Room> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        if !deniedTypes.isEmpty {
            let basePredicate = #Predicate<Room> { room in
                room.events.allSatisfy { !deniedTypes.contains($0.typeName) }
            }
            predicate = #Predicate<Room> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        if !deniedRooms.isEmpty {
            let basePredicate = #Predicate<Room> { room in
                !deniedRooms.contains(room.name)
            }
            predicate = #Predicate<Room> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        return predicate
    }

    public func trackPredicate() -> Predicate<Track> {
        var predicate: Predicate<Track> = #Predicate<Track> { _ in true }

        if onlyFuture {
            let now = Date()
            let basePredicate = #Predicate<Track> { track in
                track.events.allSatisfy({ $0.end > now })
            }
            predicate = #Predicate<Track> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        if !deniedTypes.isEmpty {
            let basePredicate = #Predicate<Track> { track in
                track.events.allSatisfy { !deniedTypes.contains($0.typeName) }
            }
            predicate = #Predicate<Track> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        if !deniedTracks.isEmpty {
            let basePredicate = #Predicate<Track> { track in
                !deniedTracks.contains(track.name)
            }
            predicate = #Predicate<Track> { predicate.evaluate($0) && basePredicate.evaluate($0) }
        }

        return predicate
    }

    private static func futurePredicate() -> Predicate<Event> {
        let now = Date()
        return #Predicate<Event> { $0.end > now }
    }

    public static func searchPredicate(_ searchText: String) -> Predicate<Event> {
        return #Predicate<Event> {
            $0.title.localizedStandardContains(searchText)
            || $0.room.name.localizedStandardContains(searchText)
            || $0.authors.contains { person in
                person.name.localizedStandardContains(searchText)
            }
        }
    }
}
