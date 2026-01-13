//
//  LinksList.swift
//  Fosdem
//
//  Created by Sean Molenaar on 15/02/2025.
//  Copyright © 2025 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct LinksList: View {
    @State var event: Event

    var body: some View {
        if event.links.isEmpty {
            Text("No links").foregroundColor(.gray)
                            .font(.title2)
                            .padding()
        } else {
            VStack(alignment: .leading) {
                ForEach(event.links.sorted { $0.name < $1.name }) { link in
                    let label = Label(link.name, systemImage: link.icon).padding()
                                                                        .frame(
                                                                            maxWidth: .infinity,
                                                                            alignment: .leading
                                                                        )
                    if link.isVideo && link.isStreamableVideo {
                        NavigationLink(destination: {
                            VStack {
                                Text(link.name).font(.title)
                                VideoPlayer(link)
                            }
                        }, label: { label })
                    } else {
                        SwiftUI.Link(destination: link.url) { label }
                    }
                }
            }
        }
    }
}

#Preview {
    LinksList(event: PreviewEvent.getEvent(false))
}
