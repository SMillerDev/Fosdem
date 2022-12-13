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

    @Environment(\.managedObjectContext) var context

    init(_ event: Event) {
        self.event = event
    }

    var body: some View {
        HStack {
            if let lastSeen = event.userInfo.lastSeen, event.lastUpdated > lastSeen {
                Rectangle().foregroundColor(.accentColor).frame(maxWidth: 1, maxHeight: .infinity)
            }
            Text(DateFormatter.localizedString(from: event.start, dateStyle: .none, timeStyle: .short) )
                .foregroundColor(.secondary)
                .italic()

            Text(event.title)
                .bold(event.userInfo.favorite)

        }.contextMenu {
            Label(event.track.name.capitalized, systemImage: event.type.icon)
            Label(event.formatTime(), systemImage: "calendar.badge.clock")
            SwiftUI.Link(destination: event.room.getNavigationLink()) {
                Label(event.room.name, systemImage: "location.circle")
            }
            if let item = Conference.roomStates.first(where: { $0.roomname == event.room.name }), item.full {
                Label("Room full", systemImage: "hand.raised").foregroundColor(.red)
            }
            ShareLink("Share web link", item: event.getPublicLink(), message: Text(event.title))
        }.swipeActions {
            Button(action: {
                print("⭐️ toggled bookmark")
                event.userInfo.favorite.toggle()
            }, label: {
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
