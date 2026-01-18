//
//  EventContainingModel.swift
//  Fosdem
//
//  Created by Sean Molenaar on 18/01/2026.
//  Copyright © 2026 Sean Molenaar. All rights reserved.
//
import SwiftData

public protocol EventContainingModel: PersistentModel {
    var events: [Event] { get set }
}

extension Track: EventContainingModel {}

extension Room: EventContainingModel {}

extension Person: EventContainingModel {}
