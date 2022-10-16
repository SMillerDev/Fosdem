//
//  RemoteScheduleSource.swift
//  Fosdem
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreData

class RemoteScheduleFetcher {
    static func fetchScheduleForYear(_ year: String) {
        let url = URL(string: "https://fosdem.org/\(year)/schedule/xml")!
        print("📲 Getting FOSDEM schedule for \(year): \(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("📲 Got FOSDEM schedule for \(year): \(url)")
            guard let data = data, error == nil else {
                print("❌ Failed to fetch schedule, \(error?.localizedDescription ?? "")")
                return
            }
            DataImporter.process(data)
        }
        task.resume()
    }
}
