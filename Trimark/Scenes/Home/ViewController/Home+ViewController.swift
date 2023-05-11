//
//  HomeViewController.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import UIKit
import Combine

extension Home {
    @objc(HomeViewController)
    class ViewController: UIViewController {
        
        // MARK: Properties - Dependencies
        /// A strong reference to the View Model that holds the business logic of this scene
        let viewModel: HomeViewModelControllable
        
        /// A video player reference
        let videoPlayer: VideoPlayer
        
        // MARK: Properties - Views
        /// A stack that contains the video view and the trim controls
        lazy var verticalStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        
        /// A view used to present trim controls. Also used to scrub the video.
        lazy var trimmingView = TrimmingView()
        
        // MARK: Properties - Navigation Bar Items
        lazy var pauseNavigationItem: UIBarButtonItem = makePlayPauseNavigationItem(play: false)
        lazy var playNavigationItem: UIBarButtonItem = makePlayPauseNavigationItem(play: true)
        lazy var watermarkingItem: UIBarButtonItem = makeWatermarkingNavigationItem()
        
        // MARK: Properties - Other
        var cancellables: Set<AnyCancellable> = []
        
        // MARK: - Initialisation
        init(
            viewModel: HomeViewModelControllable,
            videoPlayer: VideoPlayer
        ) {
            self.viewModel = viewModel
            self.videoPlayer = videoPlayer
            
            super.init(nibName: nil, bundle: nil)
            title = "Trimark"
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Life Cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            configure()
            viewModel.viewLoaded()
        }
    }
}
