//
//  YearHelper.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation

class YearHelper: ObservableObject {
    
    @Published var year: String {
        didSet {
            UserDefaults.standard.set(year, forKey: "year")
        }
    }

    init() {
        year = UserDefaults.standard.string(forKey: "year") ?? "2019"
    }
}
