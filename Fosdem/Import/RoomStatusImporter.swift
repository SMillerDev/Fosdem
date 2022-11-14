//
//  RoomStatusImporter.swift
//  Fosdem
//
//  Created by Sean Molenaar on 14/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation

class RoomStatusFetcher {
    static func fetchRoomStatus() {
        let url = URL(string: BaseURL.ROOM_STATUS.rawValue)!
        print("📲 Getting FOSDEM room data")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("📲 Got FOSDEM room data")
            
            guard let data = data, error == nil else {
                print("❌ Failed to fetch room data, \(error?.localizedDescription ?? "")")
                return
            }
            
            RoomStatusFetcher.processRoomData(data)
        }
        task.resume()
    }
    
    static func processRoomData(_ value: Data) {
        let json = try? JSONSerialization.jsonObject(with: value, options: [])
        guard let array = json as? [Any] else {
            return
        }
        
        var states: [RoomState] = []
        array.forEach { item in
            if let element = item as? [String: Any],
               let state = RoomState(json: element) {
                states.append(state)
            }
        }
        
        Conference.roomStates = states
    }
}
