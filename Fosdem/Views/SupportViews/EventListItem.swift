//
//  ListItem.swift
//  Fosdem
//
//  Created by Sean Molenaar on 15/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct EventListItem: View {
    private var event: Event
    private var bookmarkEmphasis: Bool

    @Environment(\.managedObjectContext) var context

    init(_ event: Event, bookmarkEmphasis: Bool = true, query: String? = nil) {
        self.event = event
        self.bookmarkEmphasis = bookmarkEmphasis
    }

    var body: some View {
        BaseListItem(event, bookmarkEmphasis: bookmarkEmphasis).contextMenu {
            Label(event.track?.name.capitalized ?? "TRACK", systemImage: event.type?.icon ?? "questionmark.app")
            Label(event.formatTime(), systemImage: "calendar.badge.clock")
            let room = event.room
            if room.isVirtual() {
                Label(room.name, systemImage: "message.fill")
            } else {
                SwiftUI.Link(destination: room.getNavigationLink()) {
                    Label(room.name, systemImage: "location.circle")
                }
            }

            if let item = Conference.roomStates.first(where: { $0.roomname == room.name }), item.full {
                Label("Room full", systemImage: "hand.raised").foregroundColor(.red)
            }
            ShareLink("Share web link", item: event.getPublicLink(), message: Text(event.title))
        }.swipeActions {
            Button(action: {
                event.userInfo?.favorite.toggle()
            }, label: {
                Label("Favorite", systemImage: (event.userInfo?.favorite ?? false) ? "star.slash" : "star")
            }).tint((event.userInfo?.favorite ?? false) ? .blue : .orange)
        }
        .onAppear {
            event.userInfo?.lastSeen = Date()
            try? context.save()
        }
    }
}

struct EventListItem_Previews: PreviewProvider {
    static var previews: some View {
        EventListItem(PreviewEvent.getEvent(false))
    }
}
