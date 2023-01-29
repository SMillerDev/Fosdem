//
//  Conference+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import CoreData
import SwiftyXMLParser

@objc(Conference)
public class Conference: NSManagedObject, Identifiable {
    static let elementName = "conference"

    @NSManaged public var name: String
    @NSManaged public var venue: String
    @NSManaged public var start: Date
    @NSManaged public var end: Date
    @NSManaged public var events: Set<Event>

    static var roomStates: [RoomState] = []

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conference> {
        return NSFetchRequest<Conference>(entityName: "Conference")
    }

    static func build(_ element: XML.Element) -> NSManagedObject {
        guard let name = XmlFinder.getChildString(element, element: "title") else {
            return Conference(context: DataImporter.context)
        }
        let req: NSFetchRequest<Conference> = Conference.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "name==%@", name)
        let item: Conference
        if let conf = try? req.execute().first {
            item = conf
        } else {
            item = Conference(context: DataImporter.context)
        }

        item.name = XmlFinder.getChildString(element, element: "title")!
        item.venue = XmlFinder.getChildString(element, element: "venue")!
        item.start = XmlFinder.getChildDate(element, element: "start")!
        item.end = XmlFinder.getChildDate(element, element: "end")!
        item.events = Set<Event>()

        return item
    }
}
