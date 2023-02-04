//
//  VideoPlayer.swift
//  Fosdem
//
//  Created by Sean Molenaar on 04/02/2023.
//  Copyright © 2023 Sean Molenaar. All rights reserved.
//

import SwiftUI
import AVKit

struct VideoPlayer: View {
    private var player: AVPlayer
    init(_ url: URL) {
        let player = AVPlayer(url: url)
        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        player.allowsExternalPlayback = true

        self.player = player
    }

    var body: some View {
        AVKit.VideoPlayer(player: player)
            .frame(height: 300)
            .onAppear {
                player.play()
            }
    }
}

struct VideoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayer(URL(string: "https://github.com")!)
    }
}
