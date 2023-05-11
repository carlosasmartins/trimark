//
//  HomeViewController+ViewModelDelegate.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import UIKit

// MARK: - View Model Events

/// Extension responsible for receiving events from the respective ViewModel.
extension Home.ViewController: HomeViewModelDelegate {
    func loadVideo(url: URL) {
        videoPlayer.prepare(url: url)
    }
    
    func loadThumbnails() {
        let availableSize = trimmingView.availableSizeForThumbnails()
        let numberOfThumbnails = 3
        
        let imageSize = CGSize(
            width: availableSize.width / CGFloat(numberOfThumbnails),
            height: availableSize.height
        )
        
        videoPlayer.generateVideoThumbnails(
            timeIntervalBetweenImages: videoPlayer.duration.value / TimeInterval(numberOfThumbnails),
            imageSize: imageSize,
            completion: { [weak self] images in
                self?.trimmingView.drawThumbnails(
                    images,
                    imageSize: imageSize
                )
                
                self?.viewModel.videoPlayerDidLoadThumbnails()
            }
        )
    }
    
    func prepareUi() {
        // Ideally date formatting isn't done on the view controller
        trimmingView.leftSideLabel.text = DateFormatterTool.shared.format(time: .zero)
        trimmingView.rightSideLabel.text = DateFormatterTool.shared.format(time: videoPlayer.duration.value)
    }
    
    func play() {
        videoPlayer.play()
        
        navigationItem.setLeftBarButtonItems([pauseNavigationItem, watermarkingItem], animated: true)
    }
    
    func pause() {
        videoPlayer.pause()
        
        navigationItem.setLeftBarButtonItems([playNavigationItem, watermarkingItem], animated: true)
    }
    
    func restart() {
        videoPlayer.restart()
    }
    
    func updateProgress(to percentage: TimeInterval) {
        trimmingView.progressPercentageDidUpdate(percentage)
    }
    
    func enableWatermarking(enabled: Bool) {
        videoPlayer.enableWatermarking(enabled)
    }
    
    func shareTrimmedVideo() {
        // Pause the player and disable interaction while dimming the view to indicate somthing is happening
        view.isUserInteractionEnabled = false
        view.alpha = 0.5
        pause()
        
        videoPlayer.generateVideoFromAvailablePlaybackRange { [weak self] url in
            // Restore interaction and visibility
            self?.view.isUserInteractionEnabled = true
            self?.view.alpha = 1
            
            guard let url else { return }
            
            let activityViewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            
            self?.present(activityViewController, animated: true, completion: nil)
        }
    }
}

