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

class RemoteScheduleFetcher {
    static func fetchScheduleForYear(_ year: String) {
        Alamofire.request("https://fosdem.org/\(year)/schedule/xml").responseData { data in
            guard let value = data.value, data.error == nil else {
                print("Failed to fetch schedule, \(data.error?.localizedDescription ?? "")")
                return
            }
            DataImporter.process(value)
        }
    }
}
