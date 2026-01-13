//
//  ListItem.swift
//  Fosdem
//
//  Created by Sean Molenaar on 15/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct BaseListItem: View {
    private var event: Event
    private var bookmarkEmphasis: Bool
    private var showInfoMatching: String?

    init(_ event: Event, bookmarkEmphasis: Bool = true, showInfoMatching: String? = nil) {
        self.event = event
        self.bookmarkEmphasis = bookmarkEmphasis
        self.showInfoMatching = showInfoMatching
    }

    var body: some View {
        HStack {
            ZStack(alignment: .topLeading) {
                if let lastSeen = event.userInfo?.lastSeen,
                    event.lastUpdated > lastSeen && !event.isEnded {
                    Circle()
                        .foregroundColor(.accentColor)
                        .frame(width: 10, height: 10)
                }
                VStack(alignment: .trailing) {
                    Text(event.startInFormat("EE").capitalized)
                        .foregroundColor(.secondary)
                        .italic()
                    Text(DateFormatter.localizedString(from: event.start, dateStyle: .none, timeStyle: .short) )
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            if event.isOngoing { LiveIcon() }

            VStack {
                Text(highlightedText(text: event.title, target: showInfoMatching))
                    .bold((event.userInfo?.favorite ?? false) && bookmarkEmphasis)
                    .foregroundColor(!event.isEnded ? .primary : .gray)

                if event.roomName.localizedStandardContains(showInfoMatching ?? "") {
                    Text("In: \(highlightedText(text: event.roomName, target: showInfoMatching))")
                        .font(.subheadline)
                        .scaledToFill()
                }
                if let authors = try? event.authors.filter(#Predicate {
                    $0.name.localizedStandardContains(showInfoMatching ?? "")
                }), !authors.isEmpty {
                    let authorNames = authors.map { $0.name }.joined(separator: ", ")
                    if authors.count == event.authors.count {
                        Text("By: \(highlightedText(text: authorNames, target: showInfoMatching))")
                            .font(.subheadline)
                            .scaledToFill()
                    } else {
                        Text("By: \(highlightedText(text: authorNames, target: showInfoMatching)) and others")
                            .font(.subheadline)
                            .scaledToFill()
                    }
                }
            }
        }
    }

    func highlightedText(
        text: String,
        target: String?,
        caseInsensitive: Bool = true
    ) -> AttributedString {
        var attributedText = AttributedString(text)
        guard let target = target else {
            return attributedText
        }

        // Find all ranges of the target word
        let targetRanges = text.lowercased().ranges(of: target.lowercased())

        // Return original text if target is empty or no matches
        guard !target.isEmpty, !targetRanges.isEmpty else {
            return attributedText
        }

        // Apply highlight to each range
        for range in targetRanges {
            if let startIndex = AttributedString.Index(range.lowerBound, within: attributedText),
               let endIndex = AttributedString.Index(range.upperBound, within: attributedText) {
                attributedText[startIndex..<endIndex].backgroundColor = .yellow
            }
        }

        return attributedText
    }
}

struct BaseListItem_Previews: PreviewProvider {
    static var previews: some View {
        BaseListItem(PreviewEvent.getEvent(false))
    }
}
