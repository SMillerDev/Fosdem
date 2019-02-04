//
//  Person+CoreDataClass.swift
//  
//
//  Created by Sean Molenaar on 02/02/2019.
//
//

import Foundation
import CoreData

@objc(Person)
public class Person: NSManagedObject {
    static let elementName = "person"
    static var context: NSManagedObjectContext!

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var events: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    static func build(_ id: String, name: String) -> Person {
        let req: NSFetchRequest<Person> = Person.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "id==%@", id)
        let item: Person
        if let exPerson = try? req.execute().first,
            let person = exPerson {
            item = person
        } else {
            item = Person(context: Person.context)
        }

        item.id = id
        item.name = name
        return item
    }
}
