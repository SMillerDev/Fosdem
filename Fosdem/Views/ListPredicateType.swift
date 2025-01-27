import Foundation
import SwiftUI

enum ListPredicateType {
    case person
    case room
    case track

    static var all: [ListPredicateType] {
        return [.track, .person, .room]
    }

    static func getName(_ type: ListPredicateType) -> String {
        switch type {
        case .person:
            return "People"
        case .room:
            return "Rooms"
        case .track:
            return "Tracks"
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