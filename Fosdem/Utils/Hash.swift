//
//  Hash.swift
//  Fosdem
//
//  Created by Sean Molenaar on 25/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import CryptoKit

class Hash {
    static func sha256(_ string: String) -> String {
        let messageData = string.data(using: .utf8)!

        let digest = SHA256.hash(data: messageData)

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

}
