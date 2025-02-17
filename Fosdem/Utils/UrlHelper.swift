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
        return URL(string: "\(BaseURL.navigationBase.rawValue)/\(urlName)")!
    }

    func liveStreamLink() -> URL {
        return URL(string: "https://stream.fosdem.org/\(urlName).m3u8")!
    }

    func chatLink() -> URL {
        return URL(string:
                    "https://chat.fosdem.org/#/room/%23\(SettingsHelper().year)-\(shortName.lowercased()):fosdem.org")!
    }
}

extension Event {
    func getPublicLink() -> URL {
        return URL(string: "https://fosdem.org/\(year)/schedule/event/\(slug)/")!
    }

    func chatLink() -> URL {
        let type = type?.name.lowercased() ?? "UNKNOWN"
        return URL(string: "https://chat.fosdem.org/#/room/\(room.name.lowercased())-\(type):fosdem.org")!
    }
}

extension Person {
    func getLink() -> URL {
        return URL(string: "https://fosdem.org/\(events.first!.year)/schedule/speaker/\(slug)/")!
    }
}

enum BaseURL: String {
    case navigationBase = "https://nav.fosdem.org/l"
    case schedule = "https://fosdem.org/schedule/xml"
    case roomStatus = "https://api.fosdem.org/roomstatus/v1/listrooms"
    case volunteerLink = "https://fosdem.org/volunteer/"
}
