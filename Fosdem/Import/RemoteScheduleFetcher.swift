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

@ModelActor actor DataHandler {
    fileprivate func updateOrStore(events: [PentabarfKit.Event], with rooms: [Room]) -> [Event] {
        print("💾 Saving events")
        var eventResults: [Event] = []
        events.splitInSubArrays(into: 100).forEach { eventChunk in
            let events: [Event] = eventChunk.map { eventBase in
                var event: Event? = Event.fetchWith(id: eventBase.id, modelContext)
                if event == nil {
                    let room = rooms.first { room in
                        room.name == eventBase.room
                    }
                    event = Event(eventBase, room: room!, modelContext)
                }

                print("Saving \(event!.title) with \(event!.authors.count) authors")
                modelContext.insert(event!)
                return event!
            }
            eventResults.append(contentsOf: events)

            self.save()
        }

        return eventResults
    }

    fileprivate func updateOrStore(rooms: [PentabarfKit.Room]) -> [Room] {
        print("💾 Saving rooms")
        let rooms: [Room] = rooms.map { roomBase in
            var room: Room? = Room.fetchWith(name: roomBase.name, modelContext)
            if room == nil {
                room = Room(roomBase)
            }

            modelContext.insert(room!)
            return room!
        }

        self.save()

        return rooms
    }

    fileprivate func fetchConferenceWith(name: String) -> Conference? {
        var descriptor = FetchDescriptor<Conference>(predicate: #Predicate<Conference> { base in
            base.name == name
        })
        descriptor.fetchLimit = 1

        let items = try? modelContext.fetch(descriptor)

        return items?.first
    }

    fileprivate func save() {
        do {
            try modelContext.save()
        } catch {
            debugPrint(error)
        }
    }
}
extension DataHandler: SwiftData.ModelActor {}

class RemoteScheduleFetcher {

    static var context: ModelContext!

    static func fetchSchedule() async {
        await RemoteScheduleFetcher.fetchScheduleForYear(SettingsHelper().year)
    }

    static func fetchScheduleForYear(_ year: String) async {
        let url = URL(string: "https://fosdem.org/\(year)/schedule/xml")!
        guard var conference = try? await PentabarfLoader.fetchConference(url) else {
            return
        }

        print("💾 Starting import")
        Task.detached {
            // create handler in non-main thread
            let handler = DataHandler(modelContainer: context.container)

            let rooms = await handler.updateOrStore(rooms: conference.rooms)
            let events = await handler.updateOrStore(events: conference.events, with: rooms)

            print("💾 Saving conference")
            if let conf = await handler.fetchConferenceWith(name: conference.title) {
                conf.events = events
                conf.rooms = rooms
            }

            print("💾 Saving schedule")
            await handler.save()
            print("💾 Saved schedule")
        }
    }
}
