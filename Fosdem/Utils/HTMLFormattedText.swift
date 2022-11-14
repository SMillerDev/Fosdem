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
   private  let textView = UITextView()

   init(_ content: String) {
      self.text = content
   }

   func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
      textView.widthAnchor.constraint(equalToConstant:UIScreen.main.bounds.width).isActive = true
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

  private func converHTML(text: String) -> NSAttributedString?{
      guard let data = "<style>body {font-size: 18px; text-align: justify; font-family: \(UIFont.systemFont(ofSize: 10).familyName) sans-serif;}</style> \(text)".data(using: .utf8) else {
          return nil
      }

      if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
          return attributedString
      } else{
          return nil
      }
  }
}
