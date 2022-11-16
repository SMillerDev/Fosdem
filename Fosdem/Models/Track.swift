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
import SwiftUI

@objc(Track)
public class Track: NSManagedObject, Identifiable {
    static let elementName = "track"
    static var context: NSManagedObjectContext!

    @NSManaged public var name: String
    @NSManaged public var color: String
    @NSManaged public var events: Set<Event>?

    public var eventArray: [Event] {
        let events = self.events ?? []
        return events.sorted(by:  { $0.title < $1.title })
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    var colorObject: Color {
        return Color(hexString: color)
    }

    static func build(_ element: XML.Element) -> NSManagedObject {
        let name = element.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let req: NSFetchRequest<Track> = Track.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "name==%@", name)
        let item: Track
        if let track = try? req.execute().first {
            item = track
        } else {
            item = Track(context: DataImporter.context)
            let hash = Hash.sha256(name)
            item.color = String(hash[hash.startIndex...hash.index(hash.startIndex, offsetBy: 5)])
        }

        item.name = name
        return item
    }
}

