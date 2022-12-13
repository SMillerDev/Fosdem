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
    static func fetchSchedule() {
        RemoteScheduleFetcher.fetchScheduleForYear(YearHelper().year)
    }

    static func fetchScheduleForYear(_ year: String) {
        let url = URL(string: "https://fosdem.org/\(year)/schedule/xml")!
        print("📲 Getting FOSDEM schedule for \(year): \(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("📲 Got FOSDEM schedule for \(year): \(url)")

            guard let data = data, error == nil else {
                print("❌ Failed to fetch schedule, \(error?.localizedDescription ?? "")")
                return
            }
            if let response = response as? HTTPURLResponse,
               let etag: String = response.allHeaderFields["Etag"] as? String {
                if  UserDefaults.standard.string(forKey: "etag_year") == year &&
                        UserDefaults.standard.string(forKey: "etag") == etag {
                    print("✅ No new data in FOSDEM schedule for \(year): \(url)")
                    return
                }
                UserDefaults.standard.set(year, forKey: "etag_year")
                UserDefaults.standard.set(etag, forKey: "etag")

            }
            DataImporter.process(data)
        }
        task.resume()
    }
}
