//
//  Room+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import CoreData

@objc(Room)
public class Room: NSManagedObject {
    static let elementName = "room"
    static var context: NSManagedObjectContext!

    var shortName: String {
        get { return String(describing: name?.split(separator: " ").first ?? "UNKNOWN") }
    }
    var building: String? {
        get {
            let regex = try? NSRegularExpression(pattern: "^[A-Za-z]*")
            guard let result = regex?.firstMatch(in: shortName,
                                               range: NSRange(shortName.startIndex..., in: shortName)) else {
                                                return nil
            }
            return String(shortName[Range(result.range, in: shortName)!])
        }
    }

    @NSManaged public var name: String?
    @NSManaged public var events: Set<Event>?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }

    static func build(_ element: String) -> Room {
        let req: NSFetchRequest<Room> = Room.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "name==%@", element)
        let item: Room
        if let exRoom = try? req.execute().first,
            let room = exRoom {
            item = room
        } else {
            item = Room(context: Room.context)
        }

        item.name = element
        return item
    }
}
