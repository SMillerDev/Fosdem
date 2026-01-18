//
//  BookmarkList.swift
//  Fosdem
//
//  Created by Sean Molenaar on 03/12/2024.
//  Copyright © 2024 Sean Molenaar. All rights reserved.
//
import SwiftData
import SwiftUI
import TimelineUI

struct BookmarkListView: View {
    @State private var isExpanded = false
    @Query private var events: [Event]
    @Namespace private var timelineNamespace

    var calEvents: [TimelineItem] {
        var items: [TimelineItem] = []
        for event in events {
            items.append(TimelineItem(
                title: event.title,
                startDate: event.start,
                endDate: event.end,
                color: event.track.colorObject,
                location: event.roomName
            ))
        }

        return items
    }

    init(terms: ListSettings) {
        let now = Date()
        let predicate = #Predicate<Event> { $0.userInfo?.favorite == true && $0.end > now }

        _events = Query(filter: predicate, sort: [SortDescriptor(\.start, order: .forward)])
    }

    var headerView: some View {
        HStack {
            Text("Bookmarks")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
    }

    var body: some View {
        VStack {
            CompactTimelineView(items: calEvents, heightMode: .fixed(hours: 4))
                .timelineTransition(in: timelineNamespace)
                .onTapGesture {
                    withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                        isExpanded = true
                    }
                }

            Divider()
            List(events) { event in
                NavigationLink(value: event, label: { BaseListItem(event, bookmarkEmphasis: false) })
            }.listStyle(.plain)
                .overlay(Group {
                    if events.isEmpty {
                        Label("No Bookmarks yet", systemImage: "bookmark.slash").foregroundStyle(.gray)
                    }
                })

        }.navigationTitle("Bookmarks")
            .overlay {
                if isExpanded && !events.isEmpty {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                                    isExpanded = false
                                }
                            }

                        ExpandedTimelineContent(items: calEvents) {
                            VStack(spacing: 4) {
                                Text(events.first!.start.formatted(date: .long, time: .omitted))
                                    .font(.headline)
                                Text("\(calEvents.count) events")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .timelineTransition(in: timelineNamespace)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 60)
                    }
                    .transition(.opacity)
                }
            }
    }
}
