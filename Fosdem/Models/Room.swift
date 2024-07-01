//
//  Room+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import SwiftData
import PentabarfKit

@Model
public class Room {
    @Attribute(.unique) public var name: String

    @Relationship(deleteRule: .cascade, inverse: \Event.room)
    public var events: [Event] = []

    @Transient
    var shortName: String {
        return String(describing: name.split(separator: " ").first ?? "UNKNOWN")
    }

    @Transient
    var urlName: String {
        return String(describing: shortName.replacingOccurrences(of: ".", with: "").lowercased())
    }

    @Transient
    var building: String? {
        let regex = try? Regex("^[A-Za-z]*")
        guard let result = try? regex?.firstMatch(in: shortName) else {
            return nil
        }
        return String(shortName[result.range])
    }

    convenience init(_ base: PentabarfKit.Room) {
        self.init(name: base.name)
    }

    init(name: String) {
        self.name = name
    }

    func isVirtual() -> Bool {
        return ["D", "M"].contains { $0 == building }
    }
}

extension Room {
    static func fetchWith(name: String, _ context: ModelContext) -> Room? {
        var descriptor = FetchDescriptor<Room>(predicate: #Predicate<Room> { room in
            room.name == name
        })
        descriptor.fetchLimit = 1

        let items = try? context.fetch(descriptor)

        return items?.first
    }
}
