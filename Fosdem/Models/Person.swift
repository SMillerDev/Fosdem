//
//  Person+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import SwiftData
import PentabarfKit

@Model
public class Person {

    @Attribute(.unique) public var id: Int
    public var name: String

    @Relationship(deleteRule: .cascade, inverse: \Event.authors)
    public var events: [Event]

    @Transient
    var isStaff: Bool {
        return name.lowercased().contains("staff")
    }

    @Transient
    var slug: String {
        return name.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
    }

    init(id: Int, name: String, events: [Event] = []) {
        self.id = id
        self.name = name
        self.events = events
    }

    convenience init(_ base: PentabarfKit.Person) {
        self.init(id: base.id, name: base.name)
    }
}

extension Person {
    static func fetchWith(id: Int, _ context: ModelContext) -> Person? {
        var descriptor = FetchDescriptor<Person>(predicate: #Predicate<Person> { person in
            person.id == id
        })
        descriptor.fetchLimit = 1

        let items = try? context.fetch(descriptor)

        return items?.first
    }
}
