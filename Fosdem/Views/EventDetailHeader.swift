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
                        .foregroundColor(typeColor(event.type))
                    Divider()
                    Label(formatTime(start: event.start, duration: event.duration), systemImage: "calendar.badge.clock")
                    Divider()
                    HStack{
                        Button() {
                            UIApplication.shared.open(event.room.getNavigationLink())
                        } label: { Label(event.room.name, systemImage: "location.circle") }
                        
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
            if let subtitle = event.subtitle {
                Text(subtitle)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
            }
        }
    }
    
    func typeColor(_ type: EventType) -> Color
    {
        return Color(hexString: type.color)
    }
    
    func formatTime(start: Date, duration: TimeInterval) -> String
    {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("E")
        let date = formatter.string(from: start)
        let startString = DateFormatter.localizedString(from: start, dateStyle: .none, timeStyle: .short)
        let endString = DateFormatter.localizedString(from: start.addingTimeInterval(duration), dateStyle: .none, timeStyle: .short)
        return date + " " + startString + " - " + endString
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
