//
//  DetailViewController.swift
//  Fosdem
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
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

            if let label = trackLabel {
                label.text = detail.track?.name
                label.textColor = UIColor(hexString: detail.track?.color ?? "#000000")
            }

            if let label = typeLabel {
                label.text = detail.type?.name
                label.textColor = UIColor(hexString: detail.track?.color ?? "#000000")
            }

            if let stack = buttonStack {
                if let room = detail.room, let name = room.name {
                    let button = buttonBuilder(title: "Navigate to: \(name)", action: #selector(clickLinkButton))
                    button.href = "https://nav.fosdem.org/l/\(room.urlName)"
                    stack.addArrangedSubview(button)
                }
                if let links = detail.links, !links.isEmpty {
                    links.forEach { link in
                        let button = buttonBuilder(title: link.name ?? "link", action: #selector(clickLinkButton))
                        button.href = link.href ?? "NO_URL"
                        stack.addArrangedSubview(button)
                    }
                }

                view.layoutIfNeeded()
            }
        }
    }

    func buttonBuilder(title: String, action: Selector) -> UILinkButton {
        let button = UILinkButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(view.tintColor, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.sizeToFit()
        return button
    }

    @objc func clickLinkButton(sender: UILinkButton) {
        guard let url = URL(string: sender.href) else { return }
        let svc = SFSafariViewController(url: url)
        svc.configuration.entersReaderIfAvailable = true
        present(svc, animated: true, completion: nil)
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

