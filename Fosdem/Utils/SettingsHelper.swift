//
//  YearHelper.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftUI

class SettingsHelper: ObservableObject {

    public static let DEFAULTYEAR: String = "2025"

    @AppStorage("year") var year: String = SettingsHelper.DEFAULTYEAR
}
