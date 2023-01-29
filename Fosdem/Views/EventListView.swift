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
    @State private var onlyBookmark: Bool = false
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn

    var suffix = ""

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.name, order: .forward)
        ]
    ) var personEvents: FetchedResults<Person>

    @SectionedFetchRequest(
        sectionIdentifier: \.track.name,
        sortDescriptors: [
            SortDescriptor(\.date, order: .forward),
            SortDescriptor(\.track.name, order: .forward),
            SortDescriptor(\.start, order: .forward)
        ],
        predicate: nil
    ) var trackEvents: SectionedFetchResults<String, Event>

    var body: some View {
        NavigationStack {
            TabView {
                List(trackEvents) { section in
                    Section(header: Text("\(section.id)")) {
                        ForEach(section) { event in
                            NavigationLink(value: event, label: { ListItem(event) })
                        }
                    }
                }.overlay(Group {
                    if trackEvents.isEmpty {
                        Text("Oops, loos like there's no data...")
                    }
                }).tabItem {
                    Label("Tracks", systemImage: "road.lanes")
                }.onChange(of: query) { newValue in
                    trackEvents.nsPredicate = searchPredicate(query: newValue, keypath: #keyPath(Event.title))
                }

                List(personEvents) { person in
                    Section(person.name) {
                        ForEach(Array(person.events)) { event in
                            NavigationLink(value: event, label: { ListItem(event) })
                        }
                    }
                }.onChange(of: query) { newValue in
                    personEvents.nsPredicate = searchPredicate(query: newValue, keypath: #keyPath(Person.name))
                }.tabItem {
                    Label("People", systemImage: "person")
                }.overlay(Group {
                    if personEvents.isEmpty {
                        Text("Oops, loos like there's no data...")
                    }
                })

                AboutView().tabItem {
                    Label("About", systemImage: "questionmark.bubble.fill")
                }
            }.onChange(of: onlyBookmark, perform: { value in
                let predicate = NSPredicate(format: "userInfo.favorite == YES", [])
                trackEvents.nsPredicate = value ? predicate : nil
                let personPredicate = NSPredicate(format: "ANY events.userInfo.favorite == YES", [])
                personEvents.nsPredicate = value ? personPredicate : nil
            }).searchable(
                text: $query,
                placement: .navigationBarDrawer
            ).refreshable {
                RoomStatusFetcher.fetchRoomStatus()
                RemoteScheduleFetcher.fetchSchedule()
            }.toolbar {
                Toggle(isOn: $onlyBookmark, label: { Label("Bookmarks only", systemImage: "star")})
            }.navigationDestination(for: Event.self, destination: { event in
                EventDetailView(event)
            })
        }
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
