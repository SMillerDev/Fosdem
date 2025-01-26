//
//  EventListView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI
import SwiftData
import SectionedQuery

struct EventListView: View {
    @State private var query = ""
    @State private var isSheetPresented: Bool = false
    @State private var isSearchPresented: Bool = false

    @State private var onlyBookmarks: Bool
    @State private var onlyFuture: Bool

    @StateObject private var predicate = ListSettings()

    @ModelActor public actor ScheduleFetchingActor {}
    @Environment(\.modelContext) var modelContext

    init() {
        self.onlyBookmarks = UserDefaults.standard.bool(forKey: "onlyBookmarks")
        self.onlyFuture = UserDefaults.standard.bool(forKey: "onlyFuture")
    }

    var body: some View {
        NavigationStack {
            TabView {
                TrackEventList(terms: predicate).tabItem {
                    Label("Tracks", systemImage: "road.lanes")
                }
                AuthorEventList(terms: predicate).tabItem {
                    Label("People", systemImage: "person.3")
                }
                RoomEventList(terms: predicate).tabItem {
                    Label("Rooms", systemImage: "door.left.hand.open")
                }
                BookmarkList(terms: predicate).tabItem {
                    Label("My events", systemImage: "person.circle")
                }
            }.onChange(of: onlyFuture) { value, _ in
                self.predicate.onlyFuture = value
            }.searchable(
                text: $query,
                isPresented: $isSearchPresented
            ).navigationDestination(for: Event.self, destination: { event in
                EventDetailView(event)
            })
            .toolbar {
                ToolbarItemGroup {
                    Button(action: {
                        onlyBookmarks.toggle()
                        predicate.onlyBookmarks = onlyBookmarks
                    }, label: {
                        Label("Bookmarks only", systemImage: onlyBookmarks ? "bookmark.fill" : "bookmark")
                    })
                    Button(action: {
                        onlyFuture.toggle()
                        predicate.onlyFuture = onlyFuture
                    }, label: {
                        Label("Future events only", systemImage: onlyFuture ? "clock.fill" : "clock")
                    })
                } label: {
                    Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                }
                ToolbarItem {
                    Button(action: {
                        isSheetPresented.toggle()
                    }, label: {
                        Label("Filter lists", systemImage: "slider.horizontal.2.square.on.square")
                    })
                }
            }
            .sheet(isPresented: $isSheetPresented, content: {
                SettingsView(localTime: predicate.localTime, year: predicate.year)
                    .presentationDetents([.medium])
            })
            .navigationTitle("Fosdem \(predicate.year)")
             .refreshable {
            Task {
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
