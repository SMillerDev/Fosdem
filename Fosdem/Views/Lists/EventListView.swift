//
//  TrackEventList.swift
//  Fosdem
//
//  Created by Sean Molenaar on 03/12/2024.
//  Copyright © 2024 Sean Molenaar. All rights reserved.
//
import Foundation
import SwiftData
import SwiftUI
import SectionedQuery

struct RoomEventListView: View {
    @Query private var items: [Room]
    @Query(sort: \Room.name) private var filterItems: [Room]
    @Query(sort: \EventType.name) var types: [EventType]

    private let type: ListPredicateType
    @EnvironmentObject private var terms: ListSettings

    init(terms: ListSettings) {
        self.type = .room
        _items = Query(filter: terms.roomPredicate(), sort: \.name)
    }

    var body: some View {
        HStack {
            Button(action: {
                terms.onlyFuture.toggle()
            }, label: {
                Label("Future events", systemImage: terms.onlyFuture ? "clock.fill" : "clock")
            }).buttonSizing(.fitted)
            .buttonStyle(.glass)

//            TODO: Reinstate this
//            Menu {
//                ForEach(types) { type in
//                    Button(action: {
//                        if terms.deniedTypes.contains(type.name) {
//                            terms.deniedTypes.removeAll { $0 == type.name }
//                        } else {
//                            terms.deniedTypes.append(type.name)
//                        }
//                    }, label: {
//                        let icon = "checkmark.circle"
//                        Label(type.name.capitalized,
//                              systemImage: !terms.deniedTypes.contains {
//                            $0 == type.name
//                        } ? "\(icon).fill" : icon)
//                    })
//                }
//            } label: {
//                Label("Types",
//                      systemImage: !terms.deniedTypes.isEmpty ?
//                      "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
//            }.buttonStyle(.glass)

            Menu {
                ForEach(filterItems) { room in
                    Button(action: {
                        if terms.deniedRooms.contains(room.name) {
                            terms.deniedRooms.removeAll { $0 == room.name }
                        } else {
                            terms.deniedRooms.append(room.name)
                        }
                    }, label: {
                        let icon = "checkmark.circle"
                        Label(room.name,
                              systemImage: !terms.deniedRooms.contains {
                            $0 == room.name
                        } ? "\(icon).fill" : icon)
                    })
                }
            } label: {
                Label("Rooms",
                      systemImage: !terms.deniedRooms.isEmpty ?
                      "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }.buttonStyle(.glass)
        }
        List(items, id: \.id) { item in
            Section {
                ForEach(item.events, id: \.id) { event in
                    NavigationLink(value: event,
                                   label: {
                        EventListItem(event, bookmarkEmphasis: true)
                            .id(event.id)
                    })
                }
            } header: {
                HStack {
                    if let event = item.events.first {
                        Image(systemName: event.type.icon)
                            .foregroundStyle(Color(hexString: event.track.color))
                    }
                    Text(item.name)
                }
            }
        }
        .overlay(ListStatusOverlay(empty: items.isEmpty, terms: terms))
        .listStyle(.grouped)
        .navigationTitle(ListPredicateType.getName(type))
        .refreshable {
            await RoomStatusFetcher.fetchRoomStatus()
            await RemoteScheduleFetcher.fetchSchedule()
        }
    }
}

struct TrackEventListView: View {
    @Query private var items: [Track]
    @Query(sort: \Track.name) private var filterItems: [Track]

    private let type: ListPredicateType
    @EnvironmentObject private var terms: ListSettings

    init(terms: ListSettings) {
        self.type = .track
        _items = Query(filter: terms.trackPredicate(), sort: \.name)
    }

    var body: some View {
        HStack {
            Button(action: {
                terms.onlyFuture.toggle()
            }, label: {
                Label("Future events", systemImage: terms.onlyFuture ? "clock.fill" : "clock")
            }).buttonSizing(.fitted)
            .buttonStyle(.glass)

//            TODO: Reinstate this
//            Menu {
//                ForEach(types) { type in
//                    Button(action: {
//                        if terms.deniedTypes.contains(type.name) {
//                            terms.deniedTypes.removeAll { $0 == type.name }
//                        } else {
//                            terms.deniedTypes.append(type.name)
//                        }
//                    }, label: {
//                        let icon = "checkmark.circle"
//                        Label(type.name.capitalized,
//                              systemImage: !terms.deniedTypes.contains {
//                            $0 == type.name
//                        } ? "\(icon).fill" : icon)
//                    })
//                }
//            } label: {
//                Label("Types",
//                      systemImage: !terms.deniedTypes.isEmpty ?
//                      "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
//            }.buttonStyle(.glass)

            Menu {
                ForEach(filterItems) { track in
                    Button(action: {
                        if terms.deniedTracks.contains(track.name) {
                            terms.deniedTracks.removeAll { $0 == track.name }
                        } else {
                            terms.deniedTracks.append(track.name)
                        }
                    }, label: {
                        let icon = "checkmark.circle"
                        Label(track.name,
                              systemImage: !terms.deniedTracks.contains {
                            $0 == track.name
                        } ? "\(icon).fill" : icon)
                    })
                }
            } label: {
                Label("Tracks",
                      systemImage: !terms.deniedTracks.isEmpty ?
                      "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }.buttonStyle(.glass)
        }
        List(items, id: \.id) { item in
            Section {
                ForEach(item.events, id: \.id) { event in
                    NavigationLink(value: event,
                                   label: {
                        EventListItem(event, bookmarkEmphasis: true)
                            .id(event.id)
                    })
                }
            } header: {
                HStack {
                    if let event = item.events.first {
                        Image(systemName: event.type.icon)
                            .foregroundStyle(Color(hexString: event.track.color))
                    }
                    Text(item.name)
                }
            }
        }
        .overlay(ListStatusOverlay(empty: items.isEmpty, terms: terms))
        .listStyle(.grouped)
        .navigationTitle(ListPredicateType.getName(type))
        .refreshable {
            await RoomStatusFetcher.fetchRoomStatus()
            await RemoteScheduleFetcher.fetchSchedule()
        }
    }
}
