//
//  EventListView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI
import SwiftData

struct EventListView: View {
    @State private var query = ""
    private var listPredicate: ListPredicate = ListPredicate()
    @State private var isSheetPresented: Bool = false
    @State private var bookmarks: Bool = SettingsHelper().bookmarks
    @State private var future: Bool = SettingsHelper().future
    @State private var localTime: Bool = SettingsHelper().localTime
    @State private var year: String = SettingsHelper().year
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn

    @Environment(\.modelContext) var modelContext

    @Query(sort: \Person.name) var personEvents: [Person]
    @Query(filter: #Predicate<Event> { event in
        event.userInfo?.favorite == true
    }, sort: \Event.start, order: .forward) var myEvents: [Event]
    @Query(sort: [SortDescriptor(\Track.name)]) var trackEvents: [Track]
    @Query(sort: \Room.name) var roomEvents: [Room]

    var trackList: some View {
        List(trackEvents) { track in
            Section(header: Text("\(track.name)")) {
                ForEach(track.events.sorted { $0.start >= $1.start }) { event in
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
        List(roomEvents) { _ in
//            Section(header: Text("\(room.name)")) {
//                ForEach(room.events.sorted { $0.start >= $1.start }) { event in
//                    NavigationLink(value: event, label: { ListItem(event, bookmarkEmphasis: bookmarks) })
//                }
//            }
        }.overlay(Group {
            if trackEvents.isEmpty && query.isEmpty {
                ProgressView("Still loading events").progressViewStyle(CircularProgressViewStyle())
            }
        }).listStyle(.plain)
    }

    var personList: some View {
        List(personEvents) { person in
            Section(person.name) {
                ForEach(Array(person.events.sorted { $0.start >= $1.start })) { event in
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
            }.onChange(of: year) {
                Task {
                    await RoomStatusFetcher.fetchRoomStatus()
                    await RemoteScheduleFetcher.fetchSchedule()
                }
            }.searchable(
                text: $query,
                placement: .navigationBarDrawer
            ).refreshable {
                Task {
                    await RoomStatusFetcher.fetchRoomStatus()
                    await RemoteScheduleFetcher.fetchSchedule()
                }
            }.navigationDestination(for: Event.self, destination: { event in
                EventDetailView(event)
            })
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    NavigationLink { AboutView() } label: {
                        Label("About", systemImage: "questionmark.bubble.fill")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isSheetPresented.toggle()
                    }, label: { Label("Filter lists", systemImage: "slider.horizontal.2.square.on.square")})
                        .sheet(isPresented: $isSheetPresented, content: {
                            SettingsView().presentationDetents([.medium])
                        })
                }
            }.navigationTitle("Fosdem \(year)")
            .task {
                if personEvents.isEmpty && trackEvents.isEmpty {
                    await RoomStatusFetcher.fetchRoomStatus()
                    await RemoteScheduleFetcher.fetchSchedule()
                }
            }
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
