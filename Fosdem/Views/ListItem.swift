//
//  ListItem.swift
//  Fosdem
//
//  Created by Sean Molenaar on 15/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct ListItem: View {
    @ObservedObject private var event: Event
    private var bookmarkEmphasis: Bool

    @Environment(\.managedObjectContext) var context

    init(_ event: Event, bookmarkEmphasis: Bool = true) {
        self.event = event
        self.bookmarkEmphasis = bookmarkEmphasis
    }

    var body: some View {
        HStack {
            if let lastSeen = event.userInfo.lastSeen, event.lastUpdated > lastSeen && !event.isEnded {
                Circle().foregroundColor(.accentColor)
                        .frame(width: 7, height: 7)
            }
            VStack(alignment: .trailing) {
                Text(event.startInFormat("EE").capitalized)
                    .foregroundColor(.secondary)
                    .italic()
                Text(DateFormatter.localizedString(from: event.start, dateStyle: .none, timeStyle: .short) )
                    .foregroundColor(.secondary)
                    .italic()
            }

            if event.isOngoing { LiveIcon() }

            Text(event.title)
                .bold(event.userInfo.favorite && bookmarkEmphasis)
                .foregroundColor(!event.isEnded ? .primary : .gray)

        }.contextMenu {
            Label(event.track.name.capitalized, systemImage: event.type.icon)
            Label(event.formatTime(), systemImage: "calendar.badge.clock")
            if event.room.isVirtual() {
                Label(event.room.name, systemImage: "message.fill")
            } else {
                SwiftUI.Link(destination: event.room.getNavigationLink()) {
                    Label(event.room.name, systemImage: "location.circle")
                }
            }

            if let item = Conference.roomStates.first(where: { $0.roomname == event.room.name }), item.full {
                Label("Room full", systemImage: "hand.raised").foregroundColor(.red)
            }
            ShareLink("Share web link", item: event.getPublicLink(), message: Text(event.title))
        }.swipeActions {
            Button(action: { event.userInfo.favorite.toggle() }, label: {
                Label("Favorite", systemImage: event.userInfo.favorite ? "star.fill" : "star")
            }).tint(.orange)
        }
        .onAppear {
            event.userInfo.lastSeen = Date()
            try? context.save()
        }
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(PreviewEvent.getEvent(false))
    }
}
