//
//  VideoPlayer+PlayerView.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import AVKit
import UIKit

extension VideoPlayer {
    /// A class that abstracts away the need to handle a AVPlayerLayer outside of the VideoPlayer's domain.
    class PlayerView: UIView {

        // Override the property to make AVPlayerLayer the view's backing layer.
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        
        // The associated player object.
        var player: AVPlayer? {
            get { playerLayer.player }
            set { playerLayer.player = newValue }
        }
        
        private var playerLayer: AVPlayerLayer {
            guard let layer = layer as? AVPlayerLayer else {
                preconditionFailure("Beware of the layerClass type")
            }
            
            return layer
        }
    }
}

