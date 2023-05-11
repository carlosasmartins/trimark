//
//  Home+ViewModel.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import Foundation

// MARK: - Protocols

// View Model -> View Controller Communication Bridge
protocol HomeViewModelDelegate: AnyObject {
    func loadVideo(url: URL)
    func loadThumbnails()
    func prepareUi()
    func play()
    func pause()
    func restart()
    func updateProgress(to percentage: TimeInterval)
    func shareTrimmedVideo()
    func enableWatermarking(enabled: Bool)
}

// Interface to Home.ViewModel that a UIViewController should retain.
protocol HomeViewModelControllable {
    func viewLoaded()
    
    func videoPlayerIsReadyForPlayback()
    func videoPlayerDidLoadThumbnails()
    func videoDidUpdateCurrentTime(time: TimeInterval, duration: TimeInterval, limitedDuration: TimeInterval)
    func videoDidChangePlaybackState(isPlaying: Bool)
    func playPauseActionTriggered()
    func pauseActionTriggered()
    func navigationBarMainActionTriggered()
    func watermarkingButtonTriggered(enabled: Bool)
}

// MARK: - View Model
extension Home {
    class ViewModel: HomeViewModelControllable {
        weak var delegate: HomeViewModelDelegate?
        
        // MARK: - State
        var isPlaying: Bool = false
        
        // MARK: - View Events
        func viewLoaded() {
            guard let videoUrl = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
                preconditionFailure("A demo movie should exist in this demo app")
            }
            
            delegate?.loadVideo(url: videoUrl)
        }
        
        func videoPlayerIsReadyForPlayback() {
            delegate?.loadThumbnails()
        }
        
        func videoPlayerDidLoadThumbnails() {
            delegate?.prepareUi()
        }
        
        func videoDidUpdateCurrentTime(
            time: TimeInterval,
            duration: TimeInterval,
            limitedDuration: TimeInterval
        ) {
            guard duration > 0 else { return }
            
            delegate?.updateProgress(to: time / duration)
            
            if time >= limitedDuration {
                delegate?.pause()
                delegate?.restart()
            }
        }
        
        func videoDidChangePlaybackState(isPlaying: Bool) {
            self.isPlaying = isPlaying
        }
        
        func playPauseActionTriggered() {
            isPlaying ? delegate?.pause() : delegate?.play()
        }
        
        func pauseActionTriggered() {
            guard isPlaying else {
                return
            }
            
            delegate?.pause()
        }
        
        func navigationBarMainActionTriggered() {
            delegate?.shareTrimmedVideo()
        }
        
        func watermarkingButtonTriggered(enabled: Bool) {
            delegate?.enableWatermarking(enabled: !enabled)
        }
    }
}
