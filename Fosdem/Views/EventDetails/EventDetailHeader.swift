//
//  EventDetailHeader.swift
//  Fosdem
//
//  Created by Sean Molenaar on 10/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct EventDetailHeader: View {
    private var event: Event

    init(_ event: Event) {
        self.event = event
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GroupBox(event.track?.name ?? "UNKNOWN_TRACK") {
                VStack(alignment: .leading) {
                    Label(event.type?.name.capitalized ?? "UNKNOWN_TYPE",
                          systemImage: event.type?.icon ?? "questionmark.circle.dashed")
                        .foregroundColor(event.type?.colorObject ?? .gray)

                    if let subtitle = event.subtitle {
                        Text(subtitle)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                    }
                    Divider()
                    HStack {
                        Label(event.formatTime(), systemImage: "calendar.badge.clock")
                        if event.isOngoing { LiveIcon() }
                    }
                    Divider()
                    HStack {
                        if !event.room.isVirtual() {
                            SwiftUI.Link(destination: event.room.getNavigationLink()) {
                                Label(event.room.name, systemImage: "location.circle")
                            }
                            Divider()
                        }
                        SwiftUI.Link(destination: event.room.chatLink()) {
                            Label("Chat", systemImage: "bubble.left.circle")
                        }

                        if let item = Conference.roomStates.first(where: { $0.roomname == event.room.name }) {
                            Divider()
                            Text(item.full ? "Room full" : "Room available")
                                .foregroundColor(item.full ? .red : .green)
                        }
                    }
                    Divider()
                    ForEach(Array(event.authors.sorted { $0.name < $1.name })) { author in
                        Label(author.name,
                              systemImage: author.isStaff ? "person.3" : "person")
                            .padding([.top, .bottom], 5)
                    }
                }
            }.padding(.bottom, 20)
        }
    }
}

struct EventDetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailHeader(PreviewEvent.getEvent(true)).previewLayout(.fixed(width: 400, height: 250))
            .previewDevice(.none)
            .previewDisplayName("Header Subtitle")
        EventDetailHeader(PreviewEvent.getEvent(false))
            .previewLayout(.fixed(width: 400, height: 250))
            .previewDevice(.none)
            .previewDisplayName("Header No-Subtitle")
    }
}
