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
    private var listPredicate: ListPredicate = ListPredicate()
    @State private var isSheetPresented: Bool = false
    @State private var bookmarks: Bool = false
    @State private var future: Bool = false
    @State private var localTime: Bool = false
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

    var trackList: some View {
        List(trackEvents) { section in
            Section(header: Text("\(section.id)")) {
                ForEach(section) { event in
                    NavigationLink(value: event, label: { ListItem(event, bookmarkEmphasis: bookmarks) })
                }
            }
        }.overlay(Group {
            if trackEvents.isEmpty && query.isEmpty {
                ProgressView("Still loading events").progressViewStyle(CircularProgressViewStyle())
            }
        }).listStyle(.plain)
    }

    var roomList: some View {
        List(roomEvents) { section in
            Section(header: Text("\(section.id)")) {
                ForEach(section) { event in
                    NavigationLink(value: event, label: { ListItem(event, bookmarkEmphasis: bookmarks) })
                }
            }
        }.overlay(Group {
            if trackEvents.isEmpty && query.isEmpty {
                ProgressView("Still loading events").progressViewStyle(CircularProgressViewStyle())
            }
        }).listStyle(.plain)
    }

    var personList: some View {
        List(personEvents) { person in
            Section(person.name) {
                ForEach(Array(person.events)) { event in
                    NavigationLink(value: event, label: { ListItem(event, bookmarkEmphasis: bookmarks) })
                }
            }
        }.overlay(Group {
            if personEvents.isEmpty && query.isEmpty {
                ProgressView("Still loading events").progressViewStyle(CircularProgressViewStyle())
            }
        }).listStyle(.plain)
    }

    var body: some View {
        NavigationStack {
            TabView {
                trackList.tabItem { Label("Tracks", systemImage: "road.lanes") }

                personList.tabItem { Label("People", systemImage: "person.3") }

                roomList.tabItem { Label("Rooms", systemImage: "door.left.hand.open") }

                List(myEvents) { event in
                    NavigationLink(value: event, label: { ListItem(event, bookmarkEmphasis: false) })
                }.listStyle(.plain).tabItem {
                    Label("My events", systemImage: "person.circle")
                }.overlay(Group {
                    if myEvents.isEmpty {
                        Label("No Bookmarks yet", systemImage: "bookmark.slash")
                    }
                })
            }.onChange(of: bookmarks, perform: { value in
                listPredicate.bookmarks = bookmarks
                trackEvents.nsPredicate = listPredicate.predicate(.track)
                roomEvents.nsPredicate = listPredicate.predicate(.room)
                personEvents.nsPredicate = listPredicate.predicate(.person)
            }).onChange(of: future, perform: { value in
                listPredicate.future = future
                trackEvents.nsPredicate = listPredicate.predicate(.track)
                roomEvents.nsPredicate = listPredicate.predicate(.room)
                personEvents.nsPredicate = listPredicate.predicate(.person)
            }).onChange(of: query) { newValue in
                listPredicate.searchQuery = newValue
                trackEvents.nsPredicate = listPredicate.predicate(.track)
                roomEvents.nsPredicate = listPredicate.predicate(.room)
                personEvents.nsPredicate = listPredicate.predicate(.person)
            }.searchable(
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
                                Section("Filters") {
                                    Toggle(isOn: $bookmarks, label: { Label("Bookmarks only", systemImage: "bookmark")})
                                    Toggle(isOn: $future, label: { Label("Future events only", systemImage: "clock")})
                                }
                                Section("Settings") {
                                    Toggle(isOn: $localTime, label: { Label("button.timezone.local", systemImage: "globe")})
                                }
                            }.presentationDetents([.fraction(0.3)])
                        })
                }
            }.navigationTitle("Fosdem \(YearHelper().year)")
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
