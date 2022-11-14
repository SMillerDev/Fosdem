//
//  XmlParser.swift
//  Fosdem
//
//  Created by Sean Molenaar on 07/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftyXMLParser
import CoreData

class DataImporter {
    static var conference: Conference!
    static var context: NSManagedObjectContext!

    static func process(_ value: Data) {
        print("📲 Importing Fosdem data")
        let data = XML.parse(value)
        context.perform {
            data.element?.childElements.first?.childElements.forEach { child in
                switch (child.name) {
                case Conference.elementName:
                    guard let conf = Conference.build(child) as? Conference else {
                        print("❌ No conference found")
                        return
                    }
                    DataImporter.conference =  conf
                case "day":
                    let date = child.attributes["date"]!
                    child.childElements.forEach { element in
                        element.childElements.forEach { child in
                            let event = Event.build(child, date: date) as? Event
                            event?.conference = conference
                        }
                    }
                default:
                    print("Data change")
                }
            }
            do {
                print("📲 Imported Fosdem data")
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
