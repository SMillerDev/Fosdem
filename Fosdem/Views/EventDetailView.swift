//
//  EventDetailView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 18/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct EventDetailView: View {
    private var event: Event
    
    init(_ event: Event) {
        self.event = event
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                EventDetailHeader(event)
                List(Array(event.links)) { link in
                    if let href = link.href, let url = URL(string: href) {
                        Button() {
                            UIApplication.shared.open(url)
                        } label: { Label(link.name, systemImage: link.icon) }
                    }
                }
                if let desc = event.desc {
                    HTMLFormattedText(desc)
                        .font(.body)
                }
                
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .navigationTitle(Text(event.title))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                event.favorite = !event.favorite
            } label: {
                Label("Favorite", systemImage: event.favorite ? "star.fill" : "star")
            })
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(PreviewEvent.getEvent(true)).previewDisplayName("Detail Subtitle")
        EventDetailView(PreviewEvent.getEvent(false)).previewDisplayName("Detail Non-Subtitle")
    }
}
