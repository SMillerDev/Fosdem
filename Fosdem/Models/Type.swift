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

@objc(EventType)
public class EventType: NSManagedObject {
    static let elementName = "type"
    static var context: NSManagedObjectContext!

    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var events: Set<Event>?


    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventType> {
        return NSFetchRequest<EventType>(entityName: "EventType")
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
            item = EventType(context: EventType.context)
            let hash = Hash.sha256(name)
            item.color = String(hash[hash.startIndex...hash.index(hash.startIndex, offsetBy: 5)])
        }

        item.name = name
        return item
    }
}
