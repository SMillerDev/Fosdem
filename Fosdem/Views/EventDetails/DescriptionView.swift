//
//  DescriptionView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 15/02/2025.
//  Copyright © 2025 Sean Molenaar. All rights reserved.
//

import SwiftUI
import WebKit

struct DescriptionView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var event: Event
    @State private var page = WebPage()
    @Environment(\.openURL) private var openURL

    var body: some View {
        if event.desc.isEmpty {
            Text("No description").foregroundColor(.gray)
                                  .font(.title2)
                                  .padding()
        } else if event.hasHTMLDescription {
            WebView(page)
                .webViewBackForwardNavigationGestures(.disabled)
                .webViewTextSelection(.enabled)
            .onAppear {
                page.load(html: HTMLFormattedText.get(body: event.desc), baseURL: URL(string: "about:blank")!)
            }
            .onChange(of: page.url) {
                guard let url = page.url, url.description != "about:blank" else { return }
                openURL(url)
                page.load(html: HTMLFormattedText.get(body: event.desc), baseURL: URL(string: "about:blank")!)
            }
        } else {
            Text(LocalizedStringKey(event.desc)).padding()
        }
    }
}

#Preview {
    DescriptionView(event: PreviewEvent.getEvent(false))
}
