//
//  Conference+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import SwiftData
import PentabarfKit

@Model
public class Conference {
    @Attribute(.unique)
    public var name: String
    public var venue: String
    public var start: Date
    public var end: Date

    @Relationship(deleteRule: .cascade)
    public var events: [Event] = []

    @Relationship(deleteRule: .cascade)
    public var rooms: [Room] = []

    nonisolated(unsafe) static var roomStates: [RoomState] = []

    init(name: String, venue: String, start: Date, end: Date, events: [Event] = [], rooms: [Room] = []) {
        self.name = name
        self.venue = venue
        self.start = start
        self.end = end
        self.events = events
        self.rooms = rooms
    }

    convenience init(_ base: PentabarfKit.Conference, rooms: [Room], events: [Event] = []) {
        self.init(name: base.title, venue: base.venue, start: base.start, end: base.end, events: events, rooms: rooms)
    }
}
