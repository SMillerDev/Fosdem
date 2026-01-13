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

    var isFiltering: Bool {
        onlyFuture || !deniedTypes.isEmpty
    }

    public func predicate(_ type: ListPredicateType) -> Predicate<Event>? {
        var predicate: Predicate<Event>?

        if type == .person {
            let basePredicate = #Predicate<Event> { !$0.authors.isEmpty }
            if predicate != nil {
                predicate = #Predicate<Event> { predicate!.evaluate($0) && basePredicate.evaluate($0) }
            } else {
                predicate = basePredicate
            }
        }

        if onlyFuture {
            let basePredicate = ListSettings.futurePredicate()
            if predicate != nil {
                predicate = #Predicate<Event> { predicate!.evaluate($0) && basePredicate.evaluate($0) }
            } else {
                predicate = basePredicate
            }
        }

        if !deniedTypes.isEmpty {
            let basePredicate = #Predicate<Event> {
                !deniedTypes.contains($0.typeName)
            }
            if predicate != nil {
                predicate = #Predicate<Event> { predicate!.evaluate($0) && basePredicate.evaluate($0) }
            } else {
                predicate = basePredicate
            }
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
