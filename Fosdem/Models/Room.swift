//
//  Room+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import CoreData
import SwiftyXMLParser

@objc(Room)
public class Room: NSManagedObject, ManagedObjectProtocol {
    static let elementName = "room"
    static var context: NSManagedObjectContext!

    @NSManaged public var name: String?
    @NSManaged public var events: Set<Event>?

    var shortName: String {
        get { return String(describing: name?.split(separator: " ").first ?? "UNKNOWN") }
    }
    var urlName: String {
        get { return String(describing: shortName.replacingOccurrences(of: ".", with: "").lowercased())}
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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }

    static func build(_ element: XML.Element) -> NSManagedObject? {
        let req: NSFetchRequest<Room> = Room.fetchRequest()
        guard let name = element.text else {
            return nil
        }
        req.predicate = NSComparisonPredicate(format: "name==%@", name)
        let item: Room
        if let room = try? req.execute().first {
            item = room
        } else {
            item = Room(context: Room.context)
        }

        item.name = name
        return item
    }
}
