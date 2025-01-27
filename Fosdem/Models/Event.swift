//
//  Event+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import SwiftData
import PentabarfKit

@Model
public class Event {

    @Attribute(.unique) public var id: Int
    public var title: String
    public var slug: String
    public var subtitle: String?
    public var desc: String
    public var start: Date
    public var end: Date
    public var duration: TimeInterval
    public var lastUpdated: Date = Date()

    public var room: Room
    public var track: Track!
    public var type: EventType!

    public var userInfo: EventUserInfo?

    public var authors: [Person] = []
    @Relationship(deleteRule: .cascade, inverse: \Link.event) public var links: [Link] = []

    @Transient
    public var authorName: String { return authors.first!.name}

    @Transient
    public var trackName: String { return track!.name }

    @Transient
    public var roomName: String { return room.name }

    @Transient
    var year: String { return startInFormat("yyyy") }

    @Transient
    public var day: Int { return Int(startInFormat("dd")) ?? 0 }

    @Transient
    public var isOngoing: Bool {
        let date = Date()
        return date > start && date < end
    }

    @Transient
    public var isEnded: Bool { return end < Date() }

    @Transient
    public var isFavourite: Bool {
        get { return userInfo?.favorite ?? false }
        set { userInfo?.favorite = newValue }
    }

    @Transient
    public var hasHTMLDescription: Bool {
        let matches = try? desc.matches(of: Regex("(<(.*)>(.*)</([^br]|[A-Za-z0-9]+)>)"))
        return matches != nil && !matches!.isEmpty
    }

    internal init(id: Int,
                  title: String,
                  slug: String,
                  subtitle: String? = nil,
                  desc: String,
                  start: Date,
                  duration: TimeInterval,
                  lastUpdated: Date,
                  room: Room
    ) {
        self.id = id
        self.title = title
        self.slug = slug
        self.subtitle = subtitle
        self.desc = desc
        self.start = start
        self.duration = duration
        self.end = start.addingTimeInterval(duration)
        self.lastUpdated = lastUpdated
        self.room = room
    }

    convenience init(_ base: PentabarfKit.Event, room: Room, _ context: ModelContext) {
        self.init(id: base.id,
                  title: base.title,
                  slug: base.slug,
                  subtitle: base.subtitle,
                  desc: base.description.isEmpty ? base.abstract : base.description,
                  start: base.start,
                  duration: base.duration,
                  lastUpdated: Date(),
                  room: room)
        self.userInfo = EventUserInfo(event: self)

        self.track = Track.fetchWith(name: base.track.name, context) ?? Track(name: base.track.name)
        modelContext?.insert(self.track!)

        self.type = EventType.fetchWith(name: base.type, context) ?? EventType(name: base.type)
        modelContext?.insert(self.type!)

        self.authors = base.authors.map { authorBase in
            let person = Person.fetchWith(id: authorBase.id, context) ?? Person(authorBase)
            modelContext?.insert(person)

            return person
        }

        self.links = base.links.map { linkBase in
            let link = Link.fetchWith(url: linkBase.url, context) ?? Link(linkBase)
            modelContext?.insert(link)

            return link
        } + base.attachments.map { linkBase in
            let link = Link.fetchWith(url: linkBase.url, context) ?? Link(linkBase)
            modelContext?.insert(link)

            return link
        }
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
    static func fetchWith(id: Int, _ context: ModelContext) -> Event? {
        var descriptor = FetchDescriptor<Event>(predicate: #Predicate<Event> { event in
            event.id == id
        })
        descriptor.fetchLimit = 1

        let items = try? context.fetch(descriptor)

        return items?.first
    }
}
