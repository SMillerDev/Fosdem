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

struct MainTabView: View {
    @State private var query = ""
    @State private var isSheetPresented: Bool = false
    @State private var showFilter: Bool = true

    @StateObject private var predicate: ListSettings = ListSettings()
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        TabView {
            ForEach(ListPredicateType.all, id: \.self) { type in
                Tab(ListPredicateType.getName(type), systemImage: ListPredicateType.getIcon(type)) {
                    NavigationSplitView {
                        switch type {
                        case .room:
                            RoomEventListView(terms: predicate)
                                .navigationDestination(for: Event.self) { event in
                                    EventDetailView(event)
                                }
                        case .track:
                            TrackEventListView(terms: predicate)
                                .navigationDestination(for: Event.self) { event in
                                    EventDetailView(event)
                                }
                        default:
                            EmptyView()
                        }

                    } detail: {
                        Text("Select an event")
                    }
                }
            }
            Tab("Bookmarks", systemImage: "bookmark") {
                NavigationSplitView {
                    BookmarkListView(terms: predicate)
                        .refreshable {
                            await RoomStatusFetcher.fetchRoomStatus()
                        }
                        .navigationDestination(for: Event.self) { event in
                            EventDetailView(event)
                        }
                } detail: {
                    Text("Select an event")
                }
            }
            Tab(role: .search) {
                NavigationStack {
                    SearchResultListView(query: query)
                        .searchable(text: $query, placement: .toolbar, prompt: "Search events")
                        .onAppear {
                            showFilter = false
                        }.onDisappear {
                            showFilter = true
                        }
                }
            }
        }
        .environmentObject(predicate)
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
