//
//  EventListView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct EventListView: View {
    @State private var searchText = ""
    @AppStorage("year") private var year = "2019"
    @Environment(\.managedObjectContext) var context
    @SectionedFetchRequest(
        sectionIdentifier: \.trackName,
        sortDescriptors: [NSSortDescriptor(key: "track.name", ascending: true), NSSortDescriptor(key: "start", ascending: true)],
        predicate: yearPredicate()
    ) var events: SectionedFetchResults<String, Event>

    static func yearPredicate() -> NSPredicate {
        let year = YearHelper().year
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return NSPredicate(format: "start >= %@ AND start <= %@", argumentArray: [
            formatter.date(from: "\(year)-01-01") as Any,
            formatter.date(from: "\(year)-12-31") as Any
        ])
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(events) { section in
                    Section(header: Text("\(section.id)")) {
                        ForEach(section) { event in
                            NavigationLink(destination: { EventDetailView(event)
                            }, label:  {
                                HStack {
                                    Text(DateFormatter.localizedString(from: event.start, dateStyle: .none, timeStyle: .short) )
                                        .foregroundColor(.secondary)
                                        .italic()
                                    Text(event.title)
                                        .bold(event.favorite)
                                }
                            }).onSubmit {
                                debugPrint("Tapped")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Fosdem \(year)")
            .navigationBarItems(trailing: Button("Settings", action: {
                NavigationLink(destination: {
                    SettingsView()
                }, label: { Label("Settings", systemImage: "") })
            }) )
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search events...")
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
