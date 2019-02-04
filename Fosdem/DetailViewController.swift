//
//  DetailViewController.swift
//  Fosdem
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var buttonStack: UIStackView!
    
    func htmlToAttributedString(_ string: String?) -> NSAttributedString? {
        guard let string = string,
            let data = "<style>body {font-size: 18px; text-align: justify; font-family: \(UIFont.systemFont(ofSize: 10).familyName) sans-serif;}</style> \(string)".data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            title = detail.title
            if let label = titleLabel {
                label.text = detail.authors?.first?.name
            }

            if let label = subtitleLabel {
                label.text = detail.subtitle
            }

            if let label = roomLabel {
                label.text = detail.room?.shortName
            }

            if let label = descriptionLabel {
                label.attributedText = htmlToAttributedString(detail.desc)
            }

            if let stack = buttonStack {
                let button = UIButton()
                button.setTitle(detail.room?.name, for: .normal)
                button.addTarget(self, action: #selector(clickNavButton), for: .allTouchEvents)
                stack.addArrangedSubview(button)
            }
        }
    }

    @objc func clickButton(sender: UIButton) {
        debugPrint("button \(sender)")
    }

    @objc func clickNavButton(sender: UIButton) {
        debugPrint("https://nav.fosdem.org/l/\(detailItem?.room?.shortName.lowercased() ?? "")")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

