//
//  Person+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import SwiftData

@Model
public class Track {
    @Attribute(.unique) public var name: String

    @Relationship(deleteRule: .nullify, inverse: \Event.track)
    public var events: [Event] = []

    @Transient
    public var color: String {
        let hash = Hash.sha256(name)
        return String(hash[hash.startIndex...hash.index(hash.startIndex, offsetBy: 5)])
    }

    @Transient
    public var eventArray: [Event] {
        return events.sorted { $0.title < $1.title }
    }

    init(name: String) {
        self.name = name
    }
}

extension Track {
    static func fetchWith(name: String, _ context: ModelContext) -> Track? {
        var descriptor = FetchDescriptor<Track>(predicate: #Predicate<Track> { track in
            track.name == name
        })
        descriptor.fetchLimit = 1

        let items = try? context.fetch(descriptor)

        return items?.first
    }
}
