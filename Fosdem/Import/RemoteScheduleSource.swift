//
//  RemoteScheduleSource.swift
//  Fosdem
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser
import CoreData

class RemoteScheduleSource {

    static var conference: Conference? = nil
    static func getScheduleForYear(_ year: String) {
        Alamofire.request("https://fosdem.org/\(year)/schedule/xml").responseData { data in
            guard let value = data.value, data.error == nil else {
                print("Failed to fetch schedule, \(data.error?.localizedDescription ?? "")")
                return
            }

            let data = XML.parse(value)
            Event.context.perform {
                data.element?.childElements.first?.childElements.forEach { child in
                    switch (child.name) {
                    case Conference.elementName:
                        RemoteScheduleSource.conference = Conference.build(child)
                    case "day":
                        child.childElements.forEach { element in
                            element.childElements.forEach { child in
                                _ = Event.build(child, conference: RemoteScheduleSource.conference)
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
}
