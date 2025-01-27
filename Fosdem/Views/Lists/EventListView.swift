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
    @State private var selectedEvent: Event?

    @State private var onlyBookmarks: Bool
    @State private var onlyFuture: Bool
    @State private var listType: ListPredicateType = .track

    @StateObject private var predicate = ListSettings()

    @ModelActor public actor ScheduleFetchingActor {}
    @Environment(\.modelContext) var modelContext

    init() {
        self.onlyBookmarks = UserDefaults.standard.bool(forKey: "onlyBookmarks")
        self.onlyFuture = UserDefaults.standard.bool(forKey: "onlyFuture")
    }

    var eventList: EventList {
        EventList(listType, terms: predicate)
    }

    var body: some View {
        NavigationStack {
            self.eventList
            .onChange(of: query) { value, _ in
                predicate.query = value
            }.onChange(of: isSearchPresented) { _, value in
                if value { return }
                predicate.query = nil
            }
            .searchable(text: $query, isPresented: $isSearchPresented)
            .navigationDestination(for: Event.self, destination: { event in
                EventDetailView(event)
            }).toolbar {
                ToolbarTitleMenu {
                    Picker("List grouping", selection: $listType) {
                        ForEach(ListPredicateType.all, id: \.self) { type in
                            Label(ListPredicateType.getName(type), systemImage: ListPredicateType.getIcon(type))
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
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
                        Label("Filters",
                              systemImage: predicate.isFiltering ?
                              "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isSheetPresented.toggle()
                    }, label: {
                        Label("Settings", systemImage: "gear")
                    })
                }
            }
            .sheet(isPresented: $isSheetPresented, content: {
                SettingsView(localTime: predicate.localTime, year: predicate.year)
                    .presentationDetents([.medium])
            })
            .navigationTitle(ListPredicateType.getName(listType))
            .toolbarTitleDisplayMode(.inline)
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
