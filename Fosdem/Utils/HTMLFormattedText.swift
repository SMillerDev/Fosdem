//
//  HTMLFormattedText.swift
//  Fosdem
//
//  Created by Sean Molenaar on 10/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import UIKit
import SwiftUI

struct HTMLFormattedText: UIViewRepresentable {
    let text: String
    let colorScheme: ColorScheme
    private  let textView = UITextView()

    init(_ content: String, colorScheme: ColorScheme) {
        self.text = content
        self.colorScheme = colorScheme
    }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        DispatchQueue.main.async {
            if let attributeText = self.converHTML(text: text) {
                textView.attributedText = attributeText
            } else {
                textView.text = ""
            }
        }
    }

    private func converHTML(text: String) -> NSAttributedString? {
        let color = colorScheme == .light ? "#212529" : "#f8f9fa"
        let css = """
        <style>
            body {
                color: \(color);
                font-size: 18px;
                text-align: justify;
                font-family: sans-serif;
                line-height: 1.6;
            }
        </style>
        """

        if let string = try? NSAttributedString(data: Data("\(css)\n \(text)".utf8),
                                                options: [.documentType: NSAttributedString.DocumentType.html],
                                                documentAttributes: nil) {
            return string
        } else {
            return nil
        }
    }
}
