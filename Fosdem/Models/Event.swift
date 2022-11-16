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
public class Event: NSManagedObject, ManagedObjectProtocol, Identifiable {
    static let elementName = "event"
    static var context: NSManagedObjectContext!

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var slug: String
    @NSManaged public var subtitle: String?
    @NSManaged public var desc: String?
    @NSManaged public var start: Date
    @NSManaged public var duration: TimeInterval

    @NSManaged public var favorite: Bool
    @NSManaged public var room: Room
    @NSManaged public var authors: Set<Person>
    @NSManaged public var links: Set<Link>
    @NSManaged public var conference: Conference
    @NSManaged public var track: Track
    @NSManaged public var type: EventType
    
    @objc public var trackName: String {
        return track.name
    }

    @objc public var authorName: String {
        return authors.first!.name
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: start)
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }
    
    static func build(_ element: SwiftyXMLParser.XML.Element) -> NSManagedObject? {
        return nil
    }

    func formatTime() -> String
    {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("E")
        let date = formatter.string(from: start)
        let startString = DateFormatter.localizedString(from: start, dateStyle: .none, timeStyle: .short)
        let endString = DateFormatter.localizedString(from: start.addingTimeInterval(duration), dateStyle: .none, timeStyle: .short)
        return date + " " + startString + " - " + endString
    }

    static func build(_ element: XML.Element, date: String) -> NSManagedObject? {
        guard let id = element.attributes["id"] else {
            return Event(context: DataImporter.context)
        }
        let req: NSFetchRequest<Event> = Event.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "id==%@", id)
        let item: Event
        if let event = try? req.execute().first {
            item = event
        } else {
            item = Event(context: DataImporter.context)
        }

        item.id = id
        item.title = XmlFinder.getChildString(element, element: "title")!.trimmingCharacters(in: .whitespacesAndNewlines)
        item.slug = XmlFinder.getChildString(element, element: "slug")!.trimmingCharacters(in: .whitespacesAndNewlines)
        item.subtitle = XmlFinder.getChildString(element, element: "subtitle")?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let desc = XmlFinder.getChildString(element, element: "description") {
            item.desc = desc
        }
        if let abstract = XmlFinder.getChildString(element, element: "abstract") {
            item.desc = abstract
        }

        if let room = XmlFinder.getChildElement(element, element: "room"),
           let roomObj = Room.build(room) as? Room{
            item.room = roomObj
        }
        if let track = XmlFinder.getChildElement(element, element: "track") {
            item.track = Track.build(track) as! Track
        }

        if let typeObj = XmlFinder.getChildElement(element, element: "type"),
           let type = EventType.build(typeObj) as? EventType {
            item.type = type
        }

        if let date = XmlFinder.parseDateString(date),
            let startString = XmlFinder.getChildString(element, element: "start"),
            let start = XmlFinder.parseTimeString(startString) {
            item.start = date.addingTimeInterval(start)
        }
        if let durationString = XmlFinder.getChildString(element, element: "duration"),
            let duration = XmlFinder.parseTimeString(durationString) {
            item.duration = duration
        }

        if let people = XmlFinder.getChildElement(element, element: "persons") {
            people.childElements.forEach { element in
                if let person = Person.build(element) as? Person {
                    item.authors.insert(person)
                }
            }
        }

        if let links = XmlFinder.getChildElement(element, element: "links") {
            links.childElements.forEach { element in
                if let link = Link.build(element) as? Link {
                    item.links.insert(link)
                }
            }
        }

        return item
    }
}
