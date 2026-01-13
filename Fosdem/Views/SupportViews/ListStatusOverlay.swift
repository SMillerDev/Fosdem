//
//  ListStatusOverlay.swift
//  Fosdem
//
//  Created by Sean Molenaar on 23/01/2025.
//  Copyright © 2025 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftUI

struct ListStatusOverlay: View {
    let empty: Bool
    let terms: ListSettings

    var body: some View {
        Group {
            if empty {
                if terms.isFiltering {
                    Label("All events filtered out", systemImage: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.gray)
                } else if !terms.isFiltering {
                    Label("No events", systemImage: "x.circle")
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}
