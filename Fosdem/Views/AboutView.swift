//
//  AboutView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 25/01/2023.
//  Copyright © 2023 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("""
                Hi, SMillerDev here.
                As a Homebrew maintainer and Nextcloud/news developer I love going to FOSDEM,
                but as an Apple user the apps are not as plentyful as for Android.
                That's why I made this!
                If you find this app useful, consider donating to the folowing causes:
                """)
                SwiftUI.Link(destination: URL(string: "https://u24.gov.ua")!) {
                    Label(title: {Text("Ukraine")}, icon: {  Text("🇺🇦") }).padding()
                }
                SwiftUI.Link(destination: URL(string: "https://brew.sh#homebrew-donate")!) {
                    Label(title: {Text("Homebrew")}, icon: {  Text("🍺") }).padding()
                }
                SwiftUI.Link(destination: URL(string: "https://fosdem.org/2023/support/donate/")!) {
                    Label(title: {Text("FOSDEM")}, icon: {  Text("🧑‍💻") }).padding()
                }
                Text("""
                If you have improvements you can suggest them at:
                """)
                SwiftUI.Link(destination: URL(string: "https://github.com/SMillerDev/Fosdem/issues")!) {
                    Label(title: {Text("The issue tracker")}, icon: {  Text("🔨") }).padding()
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
