//
//  Person+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import CoreData
import SwiftyXMLParser

@objc(Track)
public class Track: NSManagedObject {
    static let elementName = "track"
    static var context: NSManagedObjectContext!

    @NSManaged public var name: String?
    @NSManaged public var events: Set<Event>?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    static func build(_ element: XML.Element) -> NSManagedObject? {
        guard let name = element.text else {
                return nil
        }
        let req: NSFetchRequest<Track> = Track.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "name==%@", name)
        let item: Track
        if let exTrack = try? req.execute().first,
            let track = exTrack {
            item = track
        } else {
            item = Track(context: Track.context)
        }

        item.name = name
        return item
    }
}
