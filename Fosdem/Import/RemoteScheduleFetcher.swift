//
//  RemoteScheduleSource.swift
//  Fosdem
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import PentabarfKit
import SwiftData

class RemoteScheduleFetcher {

    static var conference: Conference?
    static var context: ModelContext!

    static func fetchSchedule() async {
        await RemoteScheduleFetcher.fetchScheduleForYear(SettingsHelper().year)
    }

    static func fetchScheduleForYear(_ year: String) async {
        let url = URL(string: "https://fosdem.org/\(year)/schedule/xml")!
        guard var conference = try? await PentabarfLoader.fetchConference(url) else {
            return
        }

        let rooms = updateOrStore(rooms: conference.rooms)
        let events = updateOrStore(events: conference.events, with: rooms)

        if let conf = Conference.fetchWith(name: conference.title, context) {
            conf.events = events
            conf.rooms = rooms

            RemoteScheduleFetcher.conference = conf
        } else {
            RemoteScheduleFetcher.conference = Conference(conference, rooms: rooms, events: events)
        }

        print("💾 Saving schedule")
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
        print("💾 Saved schedule")
    }

    private static func updateOrStore(events: [PentabarfKit.Event], with rooms: [Room]) -> [Event] {
        let events: [Event] = events.map { eventBase in
            var event: Event? = Event.fetchWith(id: eventBase.id, context)
            if event == nil {
                let room = rooms.first { room in
                    room.name == eventBase.room
                }
                event = Event(eventBase, room: room!, context)
            }

            context.insert(event!)
            return event!
        }
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }

        return events
    }

    private static func updateOrStore(rooms: [PentabarfKit.Room]) -> [Room] {
        let rooms: [Room] = rooms.map { roomBase in
            var room: Room? = Room.fetchWith(name: roomBase.name, context)
            if room == nil {
                room = Room(roomBase)
            }

            context.insert(room!)
            return room!
        }

        do {
            try context.save()
        } catch {
            debugPrint(error)
        }

        return rooms
    }
}
