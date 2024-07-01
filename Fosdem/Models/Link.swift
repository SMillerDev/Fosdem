//
//  Link.swift
//  Fosdem
//
//  Created by Sean Molenaar on 04/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftData
import PentabarfKit

@Model
public class Link {
    public var name: String
    @Attribute(originalName: "href") public var url: URL
    public var type: String

    @Relationship(deleteRule: .nullify, inverse: \Event.links)
    public var event: Event!

    @Transient
    public var isVideo: Bool {
        return type.contains(/video/) || name.lowercased().contains(/video recording/)
    }

    @Transient
    public var icon: String {
        if isVideo {
            return "video"
        } else if type.contains(/slides/) {
                return "rectangle.inset.filled.and.person.filled"
        } else {
            return "link"
        }
    }

    init(name: String, url: URL, type: String?) {
        self.name = name
        self.url = url
        self.type = type ?? "text/url"
    }

    convenience init(_ base: PentabarfKit.Link) {
        self.init(name: base.title, url: base.url, type: nil)
    }

    convenience init(_ base: PentabarfKit.Attachment) {
        self.init(name: base.title, url: base.url, type: base.type)
    }
}

extension Link {
    static func fetchWith(url: URL, _ context: ModelContext) -> Link? {
        var descriptor = FetchDescriptor<Link>(predicate: #Predicate<Link> { link in
            link.url == url
        })
        descriptor.fetchLimit = 1

        let items = try? context.fetch(descriptor)

        return items?.first
    }
}
