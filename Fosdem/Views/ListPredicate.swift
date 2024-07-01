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

//    public func predicate<T>(_ type: ListPredicateType) -> Predicate<T>? {
//        if !future && !bookmarks && searchQuery.isEmpty {
//            return nil
//        }
//
//        var predicates: [Predicate<T>] = []
//        if future {
//            self.minDatePredicateSelector(type: type, date: Date(), predicates: &predicates)
//        }
//
//        if bookmarks {
//            self.bookmarkedPredicateSelector(type: type, predicates: &predicates)
//        }
//
//        if !searchQuery.isEmpty {
//            self.searchPredicateSelector(type: type, predicates: &predicates)
//        }
//
//        return CompoundPredicate(andPredicateWithSubpredicates: predicates)
//    }
//
//    private func bookmarkedPredicateSelector(type: ListPredicateType, predicates: inout [Predicate<Any>]) {
//        switch type {
//        case .person:
//            predicates.append(Predicate(format: "ANY events.userInfo.favorite == YES"))
//        default:
//            predicates.append(Predicate(format: "userInfo.favorite == YES"))
//        }
//    }
//
//    private func minDatePredicateSelector(type: ListPredicateType, date: Date, predicates: inout [Predicate<Any>]) {
//        switch type {
//        case .person:
//            predicates.append(Predicate(format: "ANY events.start > %@", argumentArray: [date]))
//        default:
//            predicates.append(Predicate(format: "start > %@", argumentArray: [date]))
//        }
//    }
//
//    private func searchPredicateSelector(type: ListPredicateType, predicates: inout [Predicate<Any>]) {
//        switch type {
//        case .person:
//            predicates.append(searchPredicate(keypaths: [#keyPath(Person.name)]))
//        case .room:
//            predicates.append(searchPredicate(keypaths: [#keyPath(Event.room.name), #keyPath(Event.title)]))
//        case .track:
//            predicates.append(searchPredicate(keypaths: [#keyPath(Event.track.name), #keyPath(Event.title)]))
//        }
//    }
//
//    private func searchPredicate(keypaths: [String]) -> Predicate<Any> {
//        var format: [String] = []
//        var queries: [String] = []
//        keypaths.forEach { keypath in
//            format.append("%K CONTAINS[cd] %@")
//            queries.append(keypath)
//            queries.append(searchQuery)
//        }
//        return Predicate(format: format.joined(separator: " OR "), argumentArray: queries)
//    }
}

enum ListPredicateType {
    case person
    case room
    case track
}
