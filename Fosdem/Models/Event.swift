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

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var slug: String
    @NSManaged public var subtitle: String?
    @NSManaged public var desc: String?
    @NSManaged public var date: Date
    @NSManaged public var start: Date
    @NSManaged public var duration: TimeInterval
    @NSManaged public var lastUpdated: Date

    @NSManaged public var room: Room
    @NSManaged public var conference: Conference
    @NSManaged public var track: Track
    @NSManaged public var type: EventType
    @NSManaged public var userInfo: EventUserInfo
    @NSManaged public var authors: Set<Person>
    @NSManaged public var links: Set<Link>

    @objc public var authorName: String {
        return authors.first!.name
    }

    var year: String {
        return startInFormat("yyyy")
    }

    @objc public var day: Int {
        return Int(startInFormat("dd")) ?? 0
    }

    func startInFormat(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: start)
    }

    func formatTime() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("E")
        let date = formatter.string(from: start)
        let startString = DateFormatter.localizedString(from: start, dateStyle: .none, timeStyle: .short)
        let endString = DateFormatter.localizedString(from: start.addingTimeInterval(duration),
                                                      dateStyle: .none, timeStyle: .short)
        return date + " " + startString + " - " + endString
    }
}

extension Event {
    class func build(_ element: SwiftyXMLParser.XML.Element) -> NSManagedObject? {
        return nil
    }

    class func build(_ element: XML.Element, date: Date) -> NSManagedObject? {
        guard let id = element.attributes["id"] else {
            return Event(context: DataImporter.context)
        }

        let req: NSFetchRequest<Event> = NSFetchRequest<Event>(entityName: "Event")
        req.predicate = NSComparisonPredicate(format: "id==%@", id)
        let item: Event
        if let event = try? req.execute().first {
            item = event
        } else {
            item = Event(context: DataImporter.context)
            item.userInfo = EventUserInfo(context: DataImporter.context)
        }

        item.id = id
        item.lastUpdated = Date()
        item.title = XmlFinder.getChildString(element, element: "title")!
                              .trimmingCharacters(in: .whitespacesAndNewlines)
        item.slug = XmlFinder.getChildString(element, element: "slug")!
                             .trimmingCharacters(in: .whitespacesAndNewlines)
        item.subtitle = XmlFinder.getChildString(element, element: "subtitle")?
                                 .trimmingCharacters(in: .whitespacesAndNewlines)
        if let desc = XmlFinder.getChildString(element, element: "description") { item.desc = desc }
        if let abstract = XmlFinder.getChildString(element, element: "abstract") { item.desc = abstract }

        if let room = XmlFinder.getChildElement(element, element: "room"),
           let roomObj = Room.build(room) as? Room {
            item.room = roomObj
        }

        if let trackElement = XmlFinder.getChildElement(element, element: "track"),
           let track = Track.build(trackElement) as? Track {
            item.track = track
        }

        if let typeObj = XmlFinder.getChildElement(element, element: "type"),
           let type = EventType.build(typeObj) as? EventType {
            item.type = type
        }

        if let startString = XmlFinder.getChildString(element, element: "start"),
           let start = XmlFinder.parseTimeString(startString) {
            item.date = date
            item.start = date.addingTimeInterval(start)
        }

        if let durationString = XmlFinder.getChildString(element, element: "duration"),
            let duration = XmlFinder.parseTimeString(durationString) {
            item.duration = duration
        }

        item.authors = parsePeopleElement(element)
        item.links = parseLinksElement(element)

        return item
    }

    class func parsePeopleElement(_ element: XML.Element) -> Set<Person> {
        var returnVal = Set<Person>()
        guard let people = XmlFinder.getChildElement(element, element: "persons") else {
            return returnVal
        }

        people.childElements.forEach { element in
            if let person = Person.build(element) as? Person {
                returnVal.insert(person)
            }
        }

        return returnVal
    }

    class func parseLinksElement(_ element: XML.Element) -> Set<Link> {
        var returnVal = Set<Link>()
        guard let links = XmlFinder.getChildElement(element, element: "links") else {
            return returnVal
        }

        links.childElements.forEach { element in
            if let link = Link.build(element) as? Link {
                returnVal.insert(link)
            }
        }

        return returnVal
    }
}
