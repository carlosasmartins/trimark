//
//  Home.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import UIKit

enum Home {
    static func make() -> UIViewController {
        let viewModel = ViewModel()
        let viewController = ViewController(
            viewModel: viewModel,
            videoPlayer: VideoPlayer()
        )
        
        viewModel.delegate = viewController
        
        return viewController
    }
}
