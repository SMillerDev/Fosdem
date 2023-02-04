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

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.start, order: .forward)
        ],
        predicate: NSPredicate(format: "userInfo.favorite == YES", [])
    ) var myEvents: FetchedResults<Event>

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
                        ProgressView("Still loading events").progressViewStyle(CircularProgressViewStyle())
                    }
                }).tabItem {
                    Label("Tracks", systemImage: "road.lanes")
                }.onChange(of: query) { newValue in
                    trackEvents.nsPredicate = searchPredicate(query: newValue, keypaths: [#keyPath(Event.title), #keyPath(Event.track.name)])
                }.listStyle(.plain)

                List(personEvents) { person in
                    Section(person.name) {
                        ForEach(Array(person.events)) { event in
                            NavigationLink(value: event, label: { ListItem(event) })
                        }
                    }
                }.onChange(of: query) { newValue in
                    personEvents.nsPredicate = searchPredicate(query: newValue, keypaths: [#keyPath(Person.name)])
                }.tabItem {
                    Label("People", systemImage: "person.3")
                }.overlay(Group {
                    if personEvents.isEmpty {
                        ProgressView("Still loading events").progressViewStyle(CircularProgressViewStyle())
                    }
                }).listStyle(.plain)

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
                        ProgressView("Still loading events").progressViewStyle(CircularProgressViewStyle())
                    }
                }).listStyle(.plain)


                List(myEvents) { event in
                    NavigationLink(value: event, label: { ListItem(event, bookmarkEmphasis: false) })
                }.listStyle(.plain).tabItem {
                    Label("My events", systemImage: "person.circle")
                }.overlay(Group {
                    if myEvents.isEmpty {
                        Label("No Bookmarks yet", systemImage: "bookmark.slash")
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
                                Toggle(isOn: $onlyBookmark, label: { Label("Bookmarks only", systemImage: "bookmark")})
                            }.presentationDetents([.fraction(0.3)])
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
