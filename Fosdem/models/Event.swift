//
//  Event+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import CoreData
import SwiftyXMLParser

@objc(Event)
public class Event: NSManagedObject, ManagedObjectProtocol {
    static let elementName = "event"
    static var context: NSManagedObjectContext!

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var slug: String?
    @NSManaged public var desc: String?
    @NSManaged public var start: NSDate?
    @NSManaged public var duration: TimeInterval

    @NSManaged public var favorite: Bool
    @NSManaged public var room: Room?
    @NSManaged public var authors: Set<Person>?
    @NSManaged public var links: Set<Link>?
    @NSManaged public var conference: Conference?
    @NSManaged public var track: Track?
    @NSManaged public var type: EventType?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    static func build(_ element: XML.Element) -> NSManagedObject? {
        guard let id = element.attributes["id"] else {
            return Event(context: Event.context)
        }
        let req: NSFetchRequest<Event> = Event.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "id==%@", id)
        let item: Event
        if let exEvent = try? req.execute().first,
           let event = exEvent {
            item = event
        } else {
            item = Event(context: Event.context)
        }

        item.id = id
        item.title = XmlFinder.getChildString(element, element: "title")?.trimmingCharacters(in: .whitespacesAndNewlines)
        item.subtitle = XmlFinder.getChildString(element, element: "subtitle")?.trimmingCharacters(in: .whitespacesAndNewlines)
        item.slug = XmlFinder.getChildString(element, element: "slug")?.trimmingCharacters(in: .whitespacesAndNewlines)
        item.desc = XmlFinder.getChildString(element, element: "description")

        if let room = XmlFinder.getChildElement(element, element: "room") {
            item.room = Room.build(room) as? Room
        }
        if let track = XmlFinder.getChildElement(element, element: "track") {
            item.track = Track.build(track) as? Track
        }

        if let type = XmlFinder.getChildElement(element, element: "type") {
            item.type = EventType.build(type) as? EventType
        }

        if let dateString = element.parentElement?.parentElement?.attributes["date"],
            let date = XmlFinder.parseDateString(dateString),
            let startString = XmlFinder.getChildString(element, element: "start"),
            let start = XmlFinder.parseTimeString(startString) {
            item.start = date.addingTimeInterval(start) as NSDate?
        }
        if let durationString = XmlFinder.getChildString(element, element: "duration"),
            let duration = XmlFinder.parseTimeString(durationString) {
            item.duration = duration
        }

        if let people = XmlFinder.getChildElement(element, element: "persons") {
            people.childElements.forEach { element in
                if let person = Person.build(element) as? Person {
                    item.authors?.insert(person)
                }
            }
        }

        if let links = XmlFinder.getChildElement(element, element: "links") {
            links.childElements.forEach { element in
                if let link = Link.build(element) as? Link {
                    item.links?.insert(link)
                }
            }
        }

        return item
    }
}
