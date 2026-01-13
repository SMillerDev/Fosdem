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

struct EventListView: View {
    @SectionedQuery private var events: SectionedResults<String, Event>

    private let type: ListPredicateType
    @ObservedObject private var terms: ListSettings

    private var key: KeyPath<Event, String> {
        return switch type {
        case .room:
            \Event.room.name
        case .person:
            \Event.authors.first!.name
        case .track:
            \Event.track!.name
        }
    }

    init(_ type: ListPredicateType, terms: ListSettings) {
        let key = switch type {
        case .room:
            \Event.room.name
        case .person:
            \Event.authors.first!.name
        case .track:
            \Event.track!.name
        }
        self.terms = terms
        self.type = type
        _events = SectionedQuery(
            sectionIdentifier: key,
            sortDescriptors: [SortDescriptor(key, order: .forward), SortDescriptor(\.start, order: .forward)],
            predicate: terms.predicate(type),
            animation: .default
        )
    }

    var body: some View {
        List(events, id: \.id) { section in
            Section(header: Text(section.id)) {
                ForEach(section, id: \.id) { event in
                    NavigationLink(value: event,
                                   label: {
                        EventListItem(event, bookmarkEmphasis: true).id(event.id)
                    })
                }
            }
        }.overlay(ListStatusOverlay(empty: events.isEmpty, terms: terms))
        .listStyle(.plain)
        .navigationTitle(ListPredicateType.getName(type))
    }
}
