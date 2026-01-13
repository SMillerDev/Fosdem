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
    @Environment(\.modelContext) var modelContext

    @Query(sort: \EventType.name) var types: [EventType]

    var body: some View {
        TabView {
            ForEach(ListPredicateType.all, id: \.self) { type in
                Tab(ListPredicateType.getName(type), systemImage: ListPredicateType.getIcon(type)) {
                    NavigationSplitView {
                        EventListView(type, terms: predicate)
                        .navigationDestination(for: Event.self, destination: { event in
                            EventDetailView(event)
                                .onAppear {
                                    showFilter = false
                                }.onDisappear {
                                    showFilter = true
                                }
                        })
                        .refreshable {
                            Task.detached {
                                await RoomStatusFetcher.fetchRoomStatus()
                                await RemoteScheduleFetcher.fetchSchedule()
                            }
                        }
                    } detail: {
                        Text("Select an event")
                    }
                }

            }
            Tab("Bookmarks", systemImage: "bookmark") {
                NavigationSplitView {
                    BookmarkListView(terms: predicate)
                        .navigationDestination(for: Event.self, destination: { event in
                            EventDetailView(event)
                                .onAppear {
                                    showFilter = false
                                }.onDisappear {
                                    showFilter = true
                                }
                        })
                } detail: {
                    Text("Select an event")
                }
            }
            Tab(role: .search) {
                NavigationStack {
                    SearchResultListView(query: query)
                    .navigationDestination(for: Event.self, destination: { event in
                        EventDetailView(event)
                    })
                    .onAppear {
                        showFilter = false
                    }.onDisappear {
                        showFilter = true
                    }
                }.searchable(text: $query, prompt: "Search events")
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }
        }.tabViewBottomAccessory(isEnabled: showFilter) {
            HStack {
                Button(action: {
                    predicate.onlyFuture.toggle()
                }, label: {
                    Label("Future events", systemImage: predicate.onlyFuture ? "clock.fill" : "clock")
                }).padding()

                Menu {
                    ForEach(types) { type in
                        Button(action: {
                            if predicate.deniedTypes.contains(type.name) {
                                predicate.deniedTypes.removeAll { $0 == type.name }
                            } else {
                                predicate.deniedTypes.append(type.name)
                            }
                        }, label: {
                            let icon = "checkmark.circle"
                            Label(type.name.capitalized,
                                  systemImage: !predicate.deniedTypes.contains {
                                $0 == type.name
                            } ? "\(icon).fill" : icon)
                        })
                    }
                } label: {
                    Label("Types",
                          systemImage: !predicate.deniedTypes.isEmpty ?
                          "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle").padding()
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isSheetPresented.toggle()
                }, label: {
                    Label("Settings", systemImage: "gear")
                })
            }
        }
        .sheet(isPresented: $isSheetPresented, content: {
            SettingsView()
                .presentationDetents([.medium])
        })
        .environmentObject(predicate)
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
