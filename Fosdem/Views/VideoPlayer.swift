//
//  VideoPlayer.swift
//  Fosdem
//
//  Created by Sean Molenaar on 04/02/2023.
//  Copyright © 2023 Sean Molenaar. All rights reserved.
//

import SwiftUI
import AVKit

struct AVVideoPlayer: UIViewControllerRepresentable {
    let link: Link

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()

        let asset = AVURLAsset(url: link.url)
        let playerItem = AVPlayerItem(
            asset: asset,
            automaticallyLoadedAssetKeys: [.tracks, .duration, .commonMetadata]
        )

        let player = AVPlayer(playerItem: playerItem)

        playerViewController.player = player
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        playerViewController.allowsPictureInPicturePlayback = true

        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        player.allowsExternalPlayback = true

        playerViewController.player?.play()

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) { }
}

struct VideoPlayer: View {

    private let link: Link

    init(_ link: Link) {
        self.link = link
    }

    var body: some View {
        VStack {
            AVVideoPlayer(link: link)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)

            Spacer()
        }.ignoresSafeArea()
    }
}

struct VideoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        let link = Link(name: "A", url: URL(string: "https://github.com")!, type: nil)
        VideoPlayer(link)
    }
}
