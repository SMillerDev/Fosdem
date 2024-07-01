//
//  ListItem.swift
//  Fosdem
//
//  Created by Sean Molenaar on 15/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct ListItem: View {
    private var event: Event
    private var bookmarkEmphasis: Bool

    @Environment(\.managedObjectContext) var context

    init(_ event: Event, bookmarkEmphasis: Bool = true) {
        self.event = event
        self.bookmarkEmphasis = bookmarkEmphasis
    }

    var body: some View {
        HStack {
            ZStack(alignment: .topLeading) {
                if let lastSeen = event.userInfo?.lastSeen,
                    event.lastUpdated > lastSeen && !event.isEnded {
                    Circle()
                        .foregroundColor(.accentColor)
                        .frame(width: 10, height: 10)
                }
                VStack(alignment: .trailing) {
                    Text(event.startInFormat("EE").capitalized)
                        .foregroundColor(.secondary)
                        .italic()
                    Text(DateFormatter.localizedString(from: event.start, dateStyle: .none, timeStyle: .short) )
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            if event.isOngoing { LiveIcon() }

            Text(event.title)
                .bold(event.userInfo?.favorite ?? false && bookmarkEmphasis)
                .foregroundColor(!event.isEnded ? .primary : .gray)

        }.contextMenu {
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
            Button(action: { event.userInfo?.favorite.toggle() }, label: {
                Label("Favorite", systemImage: event.userInfo?.favorite ?? false ? "star.fill" : "star")
            }).tint(.orange)
        }
        .onAppear {
            event.userInfo?.lastSeen = Date()
            try? context.save()
        }
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(PreviewEvent.getEvent(false))
    }
}
