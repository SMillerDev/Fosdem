//
//  EventUserInfo.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreData

@objc(EventUserInfo)
public class EventUserInfo: NSManagedObject, Identifiable {
    @NSManaged public var favorite: Bool
    @NSManaged public var notify: Bool
    @NSManaged public var lastSeen: Date?
    @NSManaged public var event: Event
}
