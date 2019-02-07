//
//  XmlParser.swift
//  Fosdem
//
//  Created by Sean Molenaar on 07/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class DataImporter {
    static var conference: Conference!

    static func process(_ value: Data) {
        let data = XML.parse(value)
        Event.context.perform {
            data.element?.childElements.first?.childElements.forEach { child in
                switch (child.name) {
                case Conference.elementName:
                    guard let conf = Conference.build(child) as? Conference else {
                        debugPrint("No conference found")
                        return
                    }
                    DataImporter.conference =  conf
                case "day":
                    child.childElements.forEach { element in
                        element.childElements.forEach { child in
                            let event = Event.build(child) as? Event
                            event?.conference = conference
                        }
                    }
                default:
                    debugPrint("Data change")
                }
            }
            do {
                try Event.context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
