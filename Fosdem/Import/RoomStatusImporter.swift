//
//  RoomStatusImporter.swift
//  Fosdem
//
//  Created by Sean Molenaar on 14/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation

class RoomStatusFetcher {
    static func fetchRoomStatus() async {
        let url = URL(string: BaseURL.roomStatus.rawValue)!
        print("📲 Getting FOSDEM room data")
        do {
            let (data, _): (Data, URLResponse) = try await URLSession.shared.data(from: url)
            print("📲 Got FOSDEM room data")
            RoomStatusFetcher.processRoomData(data)
        } catch {
            print("❌ Failed to fetch room data")
        }
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
