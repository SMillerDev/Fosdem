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
    @State private var isSheetPresented: Bool = false
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
            SortDescriptor(\.track.name, order: .forward),
            SortDescriptor(\.start, order: .forward)
        ],
        predicate: nil
    ) var trackEvents: SectionedFetchResults<String, Event>

    @SectionedFetchRequest(
        sectionIdentifier: \.room.name,
        sortDescriptors: [
            SortDescriptor(\.room.name, order: .forward),
            SortDescriptor(\.start, order: .forward)
        ],
        predicate: nil
    ) var roomEvents: SectionedFetchResults<String, Event>

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
                    trackEvents.nsPredicate = searchPredicate(query: newValue, keypaths: [#keyPath(Event.title), #keyPath(Event.track.name)])
                }

                List(personEvents) { person in
                    Section(person.name) {
                        ForEach(Array(person.events)) { event in
                            NavigationLink(value: event, label: { ListItem(event) })
                        }
                    }
                }.onChange(of: query) { newValue in
                    personEvents.nsPredicate = searchPredicate(query: newValue, keypaths: [#keyPath(Person.name)])
                }.tabItem {
                    Label("People", systemImage: "person")
                }.overlay(Group {
                    if personEvents.isEmpty {
                        Text("Oops, loos like there's no data...")
                    }
                })

                List(roomEvents) { section in
                    Section(header: Text("\(section.id)")) {
                        ForEach(section) { event in
                            NavigationLink(value: event, label: { ListItem(event) })
                        }
                    }
                }.onChange(of: query) { newValue in
                    roomEvents.nsPredicate = searchPredicate(query: newValue, keypaths: [#keyPath(Event.room.name), #keyPath(Event.title)])
                }.tabItem {
                    Label("Rooms", systemImage: "door.left.hand.open")
                }.overlay(Group {
                    if roomEvents.isEmpty {
                        Text("Oops, loos like there's no data...")
                    }
                })
            }.onChange(of: onlyBookmark, perform: { value in
                let predicate = NSPredicate(format: "userInfo.favorite == YES", [])
                trackEvents.nsPredicate = value ? predicate : nil
                roomEvents.nsPredicate = value ? predicate : nil
                let personPredicate = NSPredicate(format: "ANY events.userInfo.favorite == YES", [])
                personEvents.nsPredicate = value ? personPredicate : nil
            }).searchable(
                text: $query,
                placement: .navigationBarDrawer
            ).refreshable {
                RoomStatusFetcher.fetchRoomStatus()
                RemoteScheduleFetcher.fetchSchedule()
            }.navigationDestination(for: Event.self, destination: { event in
                EventDetailView(event)
            }).toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    NavigationLink { AboutView() } label: {
                        Label("About", systemImage: "questionmark.bubble.fill")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isSheetPresented.toggle()
                    }, label: { Label("Filter", systemImage: "slider.horizontal.2.square.on.square")})
                        .sheet(isPresented: $isSheetPresented, content: {
                            Form {
                                Toggle(isOn: $onlyBookmark, label: { Label("Bookmarks only", systemImage: "star")})
                            }.presentationDetents([.medium])
                        })
                }
            }.navigationTitle("Fosdem \(YearHelper().year)")
        }
    }

    private func searchPredicate(query: String, keypaths: [String]) -> NSPredicate? {
        if query.isEmpty { return nil }
        var format: [String] = []
        var queries: [String] = []
        keypaths.forEach { keypath in
            format.append("%K CONTAINS[cd] %@")
            queries.append(keypath)
            queries.append(query)
        }
        return NSPredicate(format: format.joined(separator: " OR "), argumentArray: queries)
    }

}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
