//
//  EventUserInfo.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftData

@Model
/// Contains user data relating to an event
public class EventUserInfo {
    public var favorite: Bool
    public var notificationUUID: UUID?
    public var lastSeen: Date?
    public var event: Event

    public func ensureUUID() {
        if notificationUUID != nil { return }
        notificationUUID = UUID()
    }

    init(favorite: Bool = false, notificationUUID: UUID? = nil, lastSeen: Date? = nil, event: Event) {
        self.favorite = favorite
        self.notificationUUID = notificationUUID
        self.lastSeen = lastSeen
        self.event = event
    }
}
