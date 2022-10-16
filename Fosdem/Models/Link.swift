//
//  Link.swift
//  Fosdem
//
//  Created by Sean Molenaar on 04/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreData
import SwiftyXMLParser

@objc(Link)
public class Link: NSManagedObject {
    static let elementName = "link"
    static var context: NSManagedObjectContext!

    @NSManaged public var name: String?
    @NSManaged public var href: String?
    @NSManaged public var event: Event?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Link> {
        return NSFetchRequest<Link>(entityName: "Link")
    }

    static func build(_ element: XML.Element) -> NSManagedObject? {
        guard let name = element.text,
              let url = element.attributes["href"] else {
            return nil
        }
        let req: NSFetchRequest<Link> = Link.fetchRequest()
        req.predicate = NSComparisonPredicate(format: "name==%@", name)
        let item: Link
        if let link = try? req.execute().first {
            item = link
        } else {
            item = Link(context: Link.context)
        }

        item.name = name
        item.href = url
        return item
    }
}
