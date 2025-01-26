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

struct EventList: View {
    @SectionedQuery private var events: SectionedResults<String, Event>

    let terms: ListSettings

    init(_ type: ListPredicateType, terms: ListSettings) {
        let key = switch type {
        case .room:
            \Event.roomName
        case .person:
            \Event.authorName
        case .track:
            \Event.trackName
        }
        self.terms = terms
        _events = SectionedQuery(key,
                                  filter: terms.predicate(type),
                                  sort: [SortDescriptor(\.start, order: .forward)])
    }

    var body: some View {
        List(events, id: \.id) { section in
            Section(header: Text("\(section.id)")) {
                ForEach(section, id: \.id) { event in
                    NavigationLink(value: event,
                                   label: {
                        ListItem(event, bookmarkEmphasis: !terms.onlyBookmarks).id(event.id)
                    })
                }
            }
        }.overlay(ListStatusOverlay(empty: events.isEmpty, terms: terms))
        .listStyle(.plain)
    }
}
