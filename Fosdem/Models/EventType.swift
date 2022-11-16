//
//  Type.swift
//  Fosdem
//
//  Created by Sean Molenaar on 25/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreData
import SwiftyXMLParser
import SwiftUI

enum EventTypeIcon: String {
    case devroom = "keyboard"
    case keynotes = "sparkles.tv"
    case lightningtalk = "bolt"
    case maintrack = "road.lanes"
    case certification = "checkmark.seal"
    case bof = "bird"
    case none = "questionmark.circle"

    static func getIconFor(_ string: String) -> EventTypeIcon {
        switch(string.lowercased()) {
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

@objc(EventType)
public class EventType: NSManagedObject, Identifiable {
    static let elementName = "type"
    static var context: NSManagedObjectContext!

    @NSManaged public var name: String
    @NSManaged public var color: String
    @NSManaged public var events: Set<Event>

    var colorObject: Color {
        return Color(hexString: color)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventType> {
        return NSFetchRequest<EventType>(entityName: "EventType")
    }

    public var icon: String {
        return EventTypeIcon.getIconFor(name.lowercased()).rawValue
    }

    static func build(_ element: XML.Element) -> NSManagedObject? {
        guard let name = element.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        let req: NSFetchRequest<EventType> = EventType.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "name==%@", name)
        let item: EventType
        if let type = try? req.execute().first {
            item = type
        } else {
            item = EventType(context: DataImporter.context)
            let hash = Hash.sha256(name)
            item.color = String(hash[hash.startIndex...hash.index(hash.startIndex, offsetBy: 5)])
        }

        item.name = name
        return item
    }
}
