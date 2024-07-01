//
//  EventTypeIcon.swift
//  Fosdem
//
//  Created by Sean Molenaar on 20/01/2024.
//  Copyright © 2024 Sean Molenaar. All rights reserved.
//

import Foundation

enum EventTypeIcon: String {
    case devroom = "keyboard"
    case keynotes = "sparkles.tv"
    case lightningtalk = "bolt"
    case maintrack = "road.lanes"
    case certification = "checkmark.seal"
    case bof = "bird"
    case none = "questionmark.circle"

    static func getIconFor(_ string: String) -> EventTypeIcon {
        switch string.lowercased() {
        case "devroom":
            return .devroom
        case "keynotes":
            return .keynotes
        case "lightningtalk":
            return .lightningtalk
        case "maintrack":
            return .maintrack
        case "bof":
            return .bof
        case "certification":
            return .certification
        default:
            return .none
        }
    }
}
