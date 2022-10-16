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

@objc(Person)
public class Person: NSManagedObject, ManagedObjectProtocol {
    static let elementName = "person"
    static var context: NSManagedObjectContext!

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var events: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    static func build(_ element: XML.Element) -> NSManagedObject? {
        guard let id = element.attributes["id"],
            let name = element.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return nil
        }
        let req: NSFetchRequest<Person> = Person.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "id==%@", id)
        let item: Person
        if let person = try? req.execute().first {
            item = person
        } else {
            item = Person(context: Person.context)
        }

        item.id = id
        item.name = name
        return item
    }
}
