//
//  EventListView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct EventListView: View {
    @State private var query = ""
    @State private var selectedEvent: Event?

    @SectionedFetchRequest(
        sectionIdentifier: \.trackName,
        sortDescriptors: [SortDescriptor(\.track.name, order: .forward), SortDescriptor(\.start, order: .forward)],
        predicate: yearPredicate()
    ) var trackEvents: SectionedFetchResults<String, Event>

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name, order: .forward)]
    ) var personEvents: FetchedResults<Person>

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title, order: .forward)],
        predicate: NSPredicate(format: "userInfo.favorite == YES")
    ) var bookmarks: FetchedResults<Event>

    static func yearPredicate() -> NSPredicate {
        let year = YearHelper().year
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return NSPredicate(format: "start >= %@ AND start <= %@", argumentArray: [
            formatter.date(from: "\(year)-01-01") as Any,
            formatter.date(from: "\(year)-12-31") as Any
        ])
    }

    var body: some View {
        NavigationSplitView(sidebar: {
            TabView {
                List(trackEvents, selection: $selectedEvent) { section in
                    Section(header: Text("\(section.id)")) {
                        ForEach(section) { event in
                            NavigationLink(value: event, label: { ListItem(event) })
                        }
                    }
                }.tabItem {
                    Label("Tracks", systemImage: "road.lanes")
                }

                List(personEvents, selection: $selectedEvent) { person in
                    Section(person.name) {
                        ForEach(Array(person.events)) { event in
                            NavigationLink(value: event, label: { ListItem(event) })
                        }
                    }
                }.tabItem {
                    Label("People", systemImage: "person")
                }

                List(bookmarks, selection: $selectedEvent) { event in
                    NavigationLink(value: event, label: { ListItem(event) })
                }.tabItem {
                    Label("Bookmarks", systemImage: "star")
                }.badge(bookmarks.count)
            }.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic))
            .onChange(of: query) { newValue in
                trackEvents.nsPredicate = searchPredicate(query: newValue, keypath: #keyPath(Event.title))
                personEvents.nsPredicate = searchPredicate(query: newValue, keypath: #keyPath(Person.name))
            }
            .overlay(Group {
                if trackEvents.isEmpty {
                    Text("Oops, loos like there's no data...")
                }
            })
            .refreshable {
                RoomStatusFetcher.fetchRoomStatus()
                RemoteScheduleFetcher.fetchSchedule()
            }
        }, detail: {
            if let event = selectedEvent {
                EventDetailView(event)
            }
        })
    }

    private func searchPredicate(query: String, keypath: String) -> NSPredicate? {
      if query.isEmpty { return nil }
      return NSPredicate(format: "%K CONTAINS[cd] %@", keypath, query)
    }

}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
