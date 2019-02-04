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
public class Conference: NSManagedObject {
    static let elementName = "conference"
    static var context: NSManagedObjectContext!

    @NSManaged public var name: String?
    @NSManaged public var venue: String?
    @NSManaged public var start: NSDate?
    @NSManaged public var end: NSDate?
    @NSManaged public var events: Set<Event>?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conference> {
        return NSFetchRequest<Conference>(entityName: "Conference")
    }

    static func build(_ element: XML.Element) -> Conference {
        guard let name = XmlFinder.getChildString(element, element: "title") else {
            return Conference(context: Conference.context)
        }
        let req: NSFetchRequest<Conference> = Conference.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "name==%@", name)
        let item: Conference
        if let exConference = try? req.execute().first,
            let conf = exConference {
            item = conf
        } else {
            item = Conference(context: Conference.context)
        }

        item.name = XmlFinder.getChildString(element, element: "title")
        item.venue = XmlFinder.getChildString(element, element: "venue")
        item.start = XmlFinder.getChildDate(element, element: "start") as NSDate?
        item.end = XmlFinder.getChildDate(element, element: "end") as NSDate?
        item.events = Set<Event>()

        return item
    }
}
