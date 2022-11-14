//
//  RoomState.swift
//  Fosdem
//
//  Created by Sean Molenaar on 14/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation

struct RoomState {
    let id: Int
    let roominfo: String
    let roomname: String
    let full: Bool
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let roominfo = json["roominfo"] as? String,
              let roomname = json["roomname"] as? String,
              let state = json["state"] as? String
        else {
            return nil
        }

        self.id = Int(id) ?? 0
        self.roominfo = roominfo
        self.roomname = roomname
        self.full = state == "1"
    }
}
