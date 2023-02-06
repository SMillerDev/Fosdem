//
//  ListPredicate.swift
//  Fosdem
//
//  Created by Sean Molenaar on 05/02/2023.
//  Copyright © 2023 Sean Molenaar. All rights reserved.
//

import Foundation

class ListPredicate: ObservableObject {
    public var bookmarks: Bool = false
    public var future: Bool = false
    public var searchQuery: String = ""

    public func predicate(_ type: ListPredicateType) -> NSPredicate? {
        if !future && !bookmarks && searchQuery.isEmpty {
            return nil
        }

        var predicates: [NSPredicate] = []
        if bookmarks {
            switch(type) {
            case .person:
                predicates.append(NSPredicate(format: "ANY events.userInfo.favorite == YES"))
            default:
                predicates.append(NSPredicate(format: "userInfo.favorite == YES"))
            }

        }

        if future {
            let date = NSDate()
            switch(type) {
            case .person:
                predicates.append(NSPredicate(format: "ANY events.start > %@", argumentArray: [date]))
            default:
                predicates.append(NSPredicate(format: "start > %@", argumentArray: [date]))
            }
        }

        if !searchQuery.isEmpty {
            switch(type) {
            case .person:
                predicates.append(searchPredicate(keypaths: [#keyPath(Person.name)]))
            case .room:
                predicates.append(searchPredicate(keypaths: [#keyPath(Event.room.name), #keyPath(Event.title)]))
            case .track:
                predicates.append(searchPredicate(keypaths: [#keyPath(Event.track.name), #keyPath(Event.title)]))
            default:
                break
            }
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    private func searchPredicate(keypaths: [String]) -> NSPredicate {
        var format: [String] = []
        var queries: [String] = []
        keypaths.forEach { keypath in
            format.append("%K CONTAINS[cd] %@")
            queries.append(keypath)
            queries.append(searchQuery)
        }
        return NSPredicate(format: format.joined(separator: " OR "), argumentArray: queries)
    }
}

enum ListPredicateType {
    case person
    case room
    case track
}
