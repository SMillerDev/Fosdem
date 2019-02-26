//
//  UILinkButton.swift
//  Fosdem
//
//  Created by Sean Molenaar on 25/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import UIKit

class UILinkButton: UIButton {
    var href: String = "https://fosdem.org"
    override var description: String {
        return "title=\(self.title), href=\(self.href)"
    }
}
