//
//  ManagedObjectProtocol.swift
//  Fosdem
//
//  Created by Sean Molenaar on 07/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import CoreData
import SwiftyXMLParser

protocol ManagedObjectProtocol {
    static var elementName: String { get }
    static var context: NSManagedObjectContext! { get set }

    static func build(_ element: XML.Element) -> NSManagedObject?
}
