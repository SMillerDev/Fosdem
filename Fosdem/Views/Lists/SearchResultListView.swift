//
//  SearchResultListView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 13/12/2025.
//  Copyright © 2025 Sean Molenaar. All rights reserved.
//
import SwiftUI
import SwiftData

struct SearchResultListView: View {
    var query: String

    @Environment(\.modelContext) var modelContext

    @Query() var events: [Event]

    init(query: String) {
        self.query = query
        _events = Query(filter: ListSettings.searchPredicate(query), sort: \Event.title, animation: .default)
    }

    var body: some View {
        List(events) { event in
            NavigationLink(value: event, label: {
                BaseListItem(event, bookmarkEmphasis: true, showInfoMatching: query).id(event.id)
            })
        }
    }
}
