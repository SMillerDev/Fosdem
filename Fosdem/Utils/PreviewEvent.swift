//
//  PreviewEvent.swift
//  Fosdem
//
//  Created by Sean Molenaar on 14/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.

import Foundation

extension Event {
    convenience init(id: Int,
                     title: String,
                     slug: String,
                     subtitle: String? = nil,
                     desc: String,
                     start: Date,
                     duration: TimeInterval,
                     lastUpdated: Date,
                     track: Track,
                     eventType: EventType,
                     room: Room,
                     authors: [Person],
                     links: [Link]) {
        self.init(id: id,
                  title: title,
                  slug: slug,
                  subtitle: subtitle,
                  desc: desc,
                  start: start,
                  duration: duration,
                  lastUpdated: lastUpdated,
                  room: room)
        self.authors = authors
        self.links = links
    }
}

struct PreviewEvent {
    static func getEvent(_ subtitle: Bool) -> Event {
        let authors = [Person(id: 1010, name: "John Doe"), Person(id: 1011, name: "Jane Doe")]

        let track = Track(name: "Mozilla Devroom")
        let type = EventType(name: "keynote")

        let room = Room(name: "UD2.120 (Chavanne)")

        let links = [Link(name: "Some Link", url: URL(string: "https://fosdem.org")!, type: nil)]

        let start = Date()
        let duration = TimeInterval(150)
        // swiftlint:disable line_length
        let subtitle = subtitle ? "This presentation will give you an overview what to expect in the Free Software Radio devroom at FOSDEM 2022." : nil
        let desc = """
        The FOSS community suffers deeply from a fundamental paradox: every day, there are more lines of freely licensed code than ever in history, but, every day, it also becomes slightly more difficult to operate productively using only Open Source and Free Software.

        In one sense, we live in the paramount of success of FOSS: developers can easily find jobs writing mostly freely licensed software. Companies, charities, trade associations, and individual actors collaborate together on the same code bases in (relative) harmony. The entire Internet would cease to function without FOSS. Yet, the "last mile" of the most critical software that we rely on in our daily lives is usually proprietary.

        We, the presenters of this talk, live as the canaries in the coalmine of proprietary software. We have spent our lives seeking to actively avoid proprietary software but both personally and professionally, we find ourselves making compromises. In this talk, we will report the results of our diligent efforts to use only FOSS in our daily work.

        Ideally, it would be possible to live a software freedom lifestyle in the way a vegetarian lives a vegetarian lifestyle: minor inconveniences at some restaurants and stores, but generally most industrialized societies provide opportunity and resources to support that moral choice. Not so with proprietary software: often, the compromise is between "spend hours or days for a task that would take mere minutes with proprietary software". In other cases, important opportunities are simply not offered to those who chose software freedom.

        The advent of network services, which mix server-side secret software, and proprietary Javascript or "Apps", are central to the decline in the ability to live a productive, convenient life in software freedom. However, few in our community focus on the implications of this and related problems, and few now even try to resist. We have tried to resist, and while we have succeeded occasionally, we have failed overall to live life in software freedom.

        In this talk, we will report on where the resistance fails the most and why. Finally, we will make suggestions of where volunteer developers can most strategically focus their efforts to build a world where all can live in software freedom.

        """

        return Event(id: 10,
                     title: "Welcome to the Free Software Radio Devroom",
                     slug: "welcome",
                     subtitle: subtitle,
                     desc: desc,
                     start: start, duration: duration,
                     lastUpdated: Date(),
                     track: track,
                     eventType: type,
                     room: room,
                     authors: authors,
                     links: links)
        // swiftlint:enable line_length
    }
}
