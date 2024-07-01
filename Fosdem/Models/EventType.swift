//
//  Type.swift
//  Fosdem
//
//  Created by Sean Molenaar on 25/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftData

@Model
public class EventType {
    @Attribute(.unique) public var name: String

    @Relationship(deleteRule: .cascade, inverse: \Event.type)
    public var events: [Event] = []

    @Transient
    public var color: String {
        let hash = Hash.sha256(name)
        return String(hash[hash.startIndex...hash.index(hash.startIndex, offsetBy: 5)])
    }

    @Transient
    public var icon: String {
        return EventTypeIcon.getIconFor(name.lowercased()).rawValue
    }

    init(name: String) {
        self.name = name
    }
}

extension EventType {
    static func fetchWith(name: String, _ context: ModelContext) -> EventType? {
        var descriptor = FetchDescriptor<EventType>(predicate: #Predicate<EventType> { type in
            type.name == name
        })
        descriptor.fetchLimit = 1

        let items = try? context.fetch(descriptor)

        return items?.first
    }
}
