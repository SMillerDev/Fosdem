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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var isBookmarked: Bool = false
    @State private var selectedColorIndex = 0
    
    init(_ event: Event) {
        self.event = event
        self.isBookmarked = event.favorite
    }
    
    var body: some View {
            VStack(alignment: .leading) {
                EventDetailHeader(event)
                Picker(selection: $selectedColorIndex, content: {
                    if event.desc?.isEmpty == false { Text("Description").tag(0) }
                    if event.links.count > 0 { Text("Links").tag(1) }
                }, label: { Label("Test", systemImage: "a") })
                .pickerStyle(SegmentedPickerStyle())
                if selectedColorIndex == 0 {
                    if let desc = event.desc {
                        ScrollView {
                            HTMLFormattedText(desc, colorScheme: colorScheme)
                        }
                    }
                }
                if selectedColorIndex == 1 {
                    List(Array(event.links)) { link in
                        if let href = link.href, let url = URL(string: href) {
                            SwiftUI.Link(destination: url) {
                                Label(link.name, systemImage: link.icon)
                            }
                        }
                    }.listStyle(.plain)
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .navigationTitle(Text(event.title))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                event.favorite = !isBookmarked
                isBookmarked = event.favorite
            } label: {
                Label("Favorite", systemImage: isBookmarked ? "star.fill" : "star")
            })
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(PreviewEvent.getEvent(true)).previewDisplayName("Detail Subtitle")
        EventDetailView(PreviewEvent.getEvent(false)).previewDisplayName("Detail Non-Subtitle")
    }
}
