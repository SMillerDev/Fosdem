//
//  Array.swift
//  Fosdem
//
//  Created by Sean Molenaar on 26/01/2025.
//  Copyright © 2025 Sean Molenaar. All rights reserved.
//

extension Array {
    func splitInSubArrays(into size: Int) -> [[Element]] {
        return (0..<size).map {
            stride(from: $0, to: count, by: size).map { self[$0] }
        }
    }
}
