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

struct TrackEventList: View {
    @SectionedQuery private var events: SectionedResults<String, Event>

    let terms: ListSettings

    init(terms: ListSettings) {
        self.terms = terms
        _events = SectionedQuery(\.trackName,
                                  filter: terms.predicate(.track),
                                  sort: [SortDescriptor(\.start, order: .forward)])
    }

    var body: some View {
        List(events) { section in
            Section(header: Text("\(section.id)")) {
                ForEach(section) { event in
                    NavigationLink(value: event,
                                   label: {
                        ListItem(event, bookmarkEmphasis: !terms.onlyBookmarks)
                    })
                }
            }
        }.overlay(ListStatusOverlay(empty: events.isEmpty, terms: terms))
        .listStyle(.plain)
    }
}
