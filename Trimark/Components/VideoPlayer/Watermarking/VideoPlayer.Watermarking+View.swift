//
//  VideoPlayer+WatermarkingView.swift
//  Trimark
//
//  Created by Carlos Martins on 10/05/2023.
//

import MetalKit

extension VideoPlayer.Watermarking {
    /// Responsible for rendering a metal view
    class View: UIView {
        var renderer: VideoPlayer.Watermarking.Render?
        lazy var metalView = MTKView()
        
        required init() {
            super.init(frame: .zero)
            self.renderer = .init(metalView: metalView)
            
            metalView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(metalView)
            NSLayoutConstraint.activate([
                metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
                metalView.topAnchor.constraint(equalTo: topAnchor),
                metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
                metalView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
