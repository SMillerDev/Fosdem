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
    @SectionedQuery private var sections: SectionedResults<String, Event>

    private let terms: ListSettings

    init(_ type: ListPredicateType, terms: ListSettings) {
        self.terms = terms

        let key = switch type {
        case .room:
            \Event.room.name
        case .person:
            \Event.authors.first!.name
        case .track:
            \Event.track!.name
        }

        _sections = SectionedQuery(sectionIdentifier: key,
                                 sortDescriptors: [
                                    SortDescriptor(key, order: .forward),
                                    SortDescriptor(\Event.start, order: .forward)
                                 ],
                                 predicate: terms.predicate(type))
    }

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(header: Text(section.id)) {
                    ForEach(section, id: \.id) { event in
                        NavigationLink(value: event,
                                       label: {
                            ListItem(event, bookmarkEmphasis: !terms.onlyBookmarks)
                                .id(event.id)
                        })
                    }
                }
            }
        }.overlay(ListStatusOverlay(empty: sections.isEmpty, terms: terms))
            .listStyle(.plain)
    }
}
