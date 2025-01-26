//
//  ScheduleFetchingActor.swift
//  Fosdem
//
//  Created by Sean Molenaar on 14/09/2024.
//  Copyright © 2024 Sean Molenaar. All rights reserved.
//

import SwiftData

actor ScheduleFetchingActor: ModelActor {
  nonisolated let modelContainer: ModelContainer
  nonisolated let modelExecutor: any ModelExecutor

  init(modelContainer: ModelContainer) {
    let modelContext = ModelContext(modelContainer)
    self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    self.modelContainer = modelContainer
  }
}
