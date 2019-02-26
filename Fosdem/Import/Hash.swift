//
//  Hash.swift
//  Fosdem
//
//  Created by Sean Molenaar on 25/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation

class Hash {
    static func sha256(_ string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }

        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
