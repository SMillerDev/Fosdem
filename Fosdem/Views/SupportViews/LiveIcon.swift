//
//  LiveIcon.swift
//  Fosdem
//
//  Created by Sean Molenaar on 04/02/2023.
//  Copyright © 2023 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct LiveIcon: View {
    @State private var blinking: Bool = false

    var body: some View {
            Circle().foregroundColor(.red)
                .opacity(blinking ? 0 : 1)
                .frame(width: 10, height: 10)
                .animation(.easeInOut(duration: 1).repeatForever(), value: blinking)
                .onAppear {
                    withAnimation {
                        blinking = true
                    }
                }
    }
}

struct LiveIcon_Previews: PreviewProvider {
    static var previews: some View {
        LiveIcon()
    }
}
