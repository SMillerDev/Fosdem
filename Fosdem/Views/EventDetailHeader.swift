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
            GroupBox(event.track.name) {
                VStack(alignment: .leading) {
                    Text(event.type.name.capitalized)
                        .foregroundColor(event.type.colorObject)
                    if let subtitle = event.subtitle {
                        Text(subtitle)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                    }
                    Divider()
                    Label(event.formatTime(), systemImage: "calendar.badge.clock")
                    Divider()
                    HStack {
                        if event.room.isVirtual() {
                            SwiftUI.Link(destination: event.room.chatLink()) {
                                Label(event.room.name, systemImage: "message.fill")
                            }
                        } else {
                            SwiftUI.Link(destination: event.room.getNavigationLink()) {
                                Label(event.room.name, systemImage: "location.circle")
                            }
                        }

                        if let item = Conference.roomStates.first(where: { $0.roomname == event.room.name }) {
                            Text("-").foregroundColor(.secondary)
                            Text(item.full ? "Full" : "Available").foregroundColor(item.full ? .red : .green)
                        }
                    }
                    Divider()
                    ForEach(Array(event.authors)) { author in
                        Label(author.name, systemImage: "person")
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
