//
//  HTMLFormattedText.swift
//  Fosdem
//
//  Created by Sean Molenaar on 10/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct HTMLFormattedText {
    static func get(body: String) -> String {
        let bundle = Bundle.main
        let lang = bundle.preferredLocalizations.first
            ?? bundle.developmentLocalization
            ?? "en"

        return """
        <!doctype html>
        <html lang="\(lang)">
        <head>
            <meta charset="utf-8">
            <style type="text/css">
                /*
                  Custom CSS styling of HTML formatted text.
                  Note, only a limited number of CSS features are supported by NSAttributedString/UITextView.
                */

                body {
                    font: -apple-system-body;
                    font-size: 20px;
                    color: \(UIColor.secondaryLabel.hex);
                    max-width: 100%;
                    padding: 0.1em;
                    background-color: \(UIColor.systemBackground.hex);
                }
                p {
                    font-size: 20px;
                }
                h1, h2, h3, h4, h5, h6 {
                    color: \(UIColor.label.hex);
                }

                a {
                    color: \(UIColor.link.hex);
                }

                li:last-child {
                    margin-bottom: 1em;
                }
            </style>
        </head>
        <body>
            \(body)
        </body>
        </html>
        """
    }
}
