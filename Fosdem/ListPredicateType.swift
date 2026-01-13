//
//  ListPredicateType.swift
//  Fosdem
//
//  Created by Sean Molenaar on 27/01/2025.
//  Copyright © 2025 Sean Molenaar. All rights reserved.
//

import Foundation

enum ListPredicateType {
    case person
    case room
    case track

    static var all: [ListPredicateType] {
        return [.track, .room]
    }

    static func getName(_ type: ListPredicateType) -> String {
        switch type {
        case .person:
            return String(localized: "People")
        case .room:
            return String(localized: "Rooms")
        case .track:
            return String(localized: "Tracks")
        }
    }

    static func getIcon(_ type: ListPredicateType) -> String {
        switch type {
        case .person:
            return "person"
        case .room:
            return "door.left.hand.open"
        case .track:
            return "road.lanes"
        }
    }
}
