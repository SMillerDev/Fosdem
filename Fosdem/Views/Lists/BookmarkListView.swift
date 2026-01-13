//
//  BookmarkList.swift
//  Fosdem
//
//  Created by Sean Molenaar on 03/12/2024.
//  Copyright © 2024 Sean Molenaar. All rights reserved.
//
import SwiftData
import SwiftUI

struct BookmarkListView: View {
    @Query private var events: [Event]

    init(terms: ListSettings) {
        var predicate: Predicate<Event>? = #Predicate { $0.userInfo?.favorite == true }
        if terms.onlyFuture {
            let now = Date()
            let basePredicate = #Predicate<Event> { $0.end > now }
            if predicate != nil {
                predicate = #Predicate<Event> { predicate!.evaluate($0) && basePredicate.evaluate($0) }
            } else {
                predicate = basePredicate
            }
        }

        _events = Query(filter: predicate, sort: [SortDescriptor(\.start, order: .forward)])
    }

    var body: some View {
        List(events) { event in
            NavigationLink(value: event, label: { BaseListItem(event, bookmarkEmphasis: false) })
        }.listStyle(.plain)
        .overlay(Group {
            if events.isEmpty {
                Label("No Bookmarks yet", systemImage: "bookmark.slash").foregroundStyle(.gray)
            }
        }).navigationTitle("Bookmarks")
    }
}
