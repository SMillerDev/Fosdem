//
//  UrlHelper.swift
//  Fosdem
//
//  Created by Sean Molenaar on 14/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation

extension Room {
    func getNavigationLink() -> URL {
        return URL(string: "\(BaseURL.NAV.rawValue)/\(urlName)")!
    }
}

extension Event {
    func getPublicLink() -> URL {
        return URL(string: "https://fosdem.org/\(year)/schedule/event/\(slug)/")!
    }
}

extension Person {
    func getLink() -> URL {
        return URL(string: "https://fosdem.org/\(events.first!.year)/schedule/speaker/\(slug)/")!
    }
}

enum BaseURL: String {
    case NAV = "https://nav.fosdem.org/l"
    case SCHEDULE = "https://fosdem.org/schedule/xml"
    case ROOM_STATUS = "https://api.fosdem.org/roomstatus/v1/listrooms"
    case VOLUNTEER_LINK = "https://fosdem.org/volunteer/"
}
