//
//  XmlFinder.swift
//  Fosdem
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class XmlFinder {
    static func getChildString(_ object: XML.Element, element: String) -> String? {
        return XmlFinder.getChildElement(object, element: element)?.text
    }

    static func getChildDate(_ object: XML.Element, element: String) -> Date? {
        guard let text = XmlFinder.getChildElement(object, element: element)?.text else {
            return nil
        }
        return parseDateString(text)
    }

    static func parseDateString(_ element: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: "\(element)T00:00:00Z")
    }

    static func parseTimeString(_ element: String, base: Date? = nil) -> TimeInterval? {
        let time = element.split(separator: ":")
        guard let hoursString = time.first,
            let minutesString = time.last,
            let hours = Int(hoursString),
            let minutes = Int(minutesString) else {
            return nil
        }
        let interval = (hours * 60 + minutes) * 60
        guard let base = base else {
            return Double(interval)
        }
        let date = base.addingTimeInterval(Double(interval))
        return date.timeIntervalSince(base)
    }

    static func getChildElement(_ object: XML.Element, element: String) -> XML.Element? {
        return object.childElements.first { $0.name == element }
    }
}
