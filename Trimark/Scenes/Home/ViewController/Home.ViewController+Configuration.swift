//
//  HomeViewController+Configuration.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import UIKit

// MARK: - Initial Setup

extension Home.ViewController {
    func configure() {
        configureStyle()
        configureNavigationItems()
        configureViews()
        bindVideoPlayerEventsToViewModel()
        configureTrimmingView()
    }
    
    private func configureStyle() {
        view.backgroundColor = .white
        videoPlayer.view.backgroundColor = .black
    }
    
    private func configureNavigationItems() {
        // Creates a disabled left-side navigation bar item to play/pause
        navigationItem.leftBarButtonItems = [playNavigationItem, watermarkingItem]
        
        // Creates a right-side navigation bar item to trigger the main system action.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .action,
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.viewModel.navigationBarMainActionTriggered()
                }
            )
        )
    }
    
    private func configureViews() {
        // Adds the vertical stack
        view.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.backgroundColor = .lightGray
        
        // Bounds it to the safe layout guides
        let verticalStackConstraints: [NSLayoutConstraint] = [
            verticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        // Adds the player view
        verticalStackView.addArrangedSubview(videoPlayer.view)
        videoPlayer.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Adds the trimming controls
        verticalStackView.addArrangedSubview(trimmingView)
        trimmingView.translatesAutoresizingMaskIntoConstraints = false
        
        // An height limiter to the trimming view
        let trimmingViewHeightConstraint = trimmingView.heightAnchor.constraint(
            equalToConstant: Constants.trimmingControlsHeight
        )
        
        // Activate all constraints at the same time
        NSLayoutConstraint.activate(verticalStackConstraints + [trimmingViewHeightConstraint])
    }
    
    private func configureTrimmingView() {
        trimmingView.delegate = self
    }
}

// MARK: - Navigation Bar Item Builders
extension Home.ViewController {
    func makePlayPauseNavigationItem(play: Bool) -> UIBarButtonItem {
        UIBarButtonItem(
            systemItem: play ? .play : .pause,
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.viewModel.playPauseActionTriggered()
                }
            )
        )
    }
    
    func makeWatermarkingNavigationItem() -> UIBarButtonItem {
        UIBarButtonItem(
            image: .init(systemName: "w.circle"),
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.viewModel.watermarkingButtonTriggered(
                        enabled: self?.videoPlayer.isWatermarkingEnabled == true
                    )
                }
            )
        )
    }
}

extension Home.ViewController {
    enum Constants {
        static var trimmingControlsHeight: Double = 200
    }
}
