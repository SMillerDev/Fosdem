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

    init(_ event: Event) {
        self.event = event
    }

    var body: some View {
        HStack {
            Text(DateFormatter.localizedString(from: event.start, dateStyle: .none, timeStyle: .short) )
                .foregroundColor(.secondary)
                .italic()
            Text(event.title)
                .bold(event.favorite)
        }.contextMenu {
            Label(event.track.name.capitalized, systemImage: event.type.icon)
            Label(event.formatTime(), systemImage: "calendar.badge.clock")
            SwiftUI.Link(destination: event.room.getNavigationLink()) {
                Label(event.room.name, systemImage: "location.circle")
            }
            if let item = Conference.roomStates.first(where: { $0.roomname == event.room.name }), item.full  {
                Label("Room full", systemImage: "hand.raised").foregroundColor(.red)
            }
            ShareLink("Share web link", item: event.getPublicLink(), message: Text(event.title))
        }
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(PreviewEvent.getEvent(false))
    }
}
