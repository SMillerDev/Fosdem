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
    @AppStorage(wrappedValue: false, "onlyBookmarks") var onlyBookmarks: Bool
    @AppStorage(wrappedValue: false, "onlyFuture") var onlyFuture: Bool
    @AppStorage(wrappedValue: false, "localTime") var localTime: Bool
    @AppStorage(wrappedValue: SettingsHelper.DEFAULTYEAR, "year") var year: String

    @Published var query: String?

    var isFiltering: Bool {
        onlyBookmarks || onlyFuture || ( query != nil && !query!.isEmpty )
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

        if onlyBookmarks {
            let basePredicate = #Predicate<Event> { $0.userInfo?.favorite ?? false }
            if predicate != nil {
                predicate = #Predicate<Event> { predicate!.evaluate($0) && basePredicate.evaluate($0) }
            } else {
                predicate = basePredicate
            }
        }
        if onlyFuture {
            let now = Date()
            let basePredicate = #Predicate<Event> { $0.end > now }
            if predicate != nil {
                predicate = #Predicate<Event> { predicate!.evaluate($0) && basePredicate.evaluate($0) }
            } else {
                predicate = basePredicate
            }
        }
        if let query = query, !query.isEmpty {
            let basePredicate = #Predicate<Event> {
                $0.title.localizedStandardContains(query) || $0.trackName.localizedStandardContains(query)
            }
            if predicate != nil {
                predicate = #Predicate<Event> { predicate!.evaluate($0) && basePredicate.evaluate($0) }
            } else {
                predicate = basePredicate
            }
        }

        return predicate
    }
}

enum ListPredicateType {
    case person
    case room
    case track
}
