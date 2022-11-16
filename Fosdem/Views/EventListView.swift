//
//  EventListView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct EventListView: View {
    @State private var query = ""
    @AppStorage("year") private var year = "2019"
    @Environment(\.managedObjectContext) var context
    @SectionedFetchRequest(
        sectionIdentifier: \.trackName,
        sortDescriptors: [NSSortDescriptor(key: "track.name", ascending: true), NSSortDescriptor(key: "start", ascending: true)],
        predicate: yearPredicate()
    ) var trackEvents: SectionedFetchResults<String, Event>

    @FetchRequest(
        entity: Person.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) var personEvents: FetchedResults<Person>

    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)],
        predicate: NSPredicate(format: "favorite == YES")
    ) var bookmarks: FetchedResults<Event>

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
            TabView{
                List {
                    ForEach(trackEvents) { section in
                        Section(header: Text("\(section.id)")) {
                            ForEach(section) { event in
                                NavigationLink(destination: {
                                    EventDetailView(event)
                                }, label:  {
                                    ListItem(event)
                                })
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Tracks", systemImage: "road.lanes")
                }
                List(personEvents) { person in
                    Section(person.name) {
                        ForEach(Array(person.events)) { event in
                            NavigationLink(destination: {
                                EventDetailView(event)
                            }, label:  {
                                ListItem(event)
                            })
                        }
                    }
                }.tabItem {
                    Label("People", systemImage: "person")
                }
                List(bookmarks) { event in
                    NavigationLink(destination: {
                        EventDetailView(event)
                    }, label:  {
                        ListItem(event)
                    })
                }.tabItem {
                    Label("Bookmarks", systemImage: "star")
                }
            }
        }.navigationTitle("Fosdem \(year)")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic))
            .onChange(of: query) { newValue in
                trackEvents.nsPredicate = searchPredicate(query: newValue, keypath: #keyPath(Event.title))
                personEvents.nsPredicate = searchPredicate(query: newValue, keypath: #keyPath(Person.name))
            }
    }

    private func searchPredicate(query: String, keypath: String) -> NSPredicate? {
      if query.isEmpty { return nil }
      return NSPredicate(format: "%K CONTAINS[cd] %@", keypath, query)
    }

}


struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
