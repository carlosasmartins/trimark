//
//  Home.ViewController+VideoPlayerEvents.swift
//  Trimark
//
//  Created by Carlos Martins on 09/05/2023.
//

import Combine
import UIKit

extension Home.ViewController {
    func bindVideoPlayerEventsToViewModel() {
        videoPlayer
            .isReadyForPlayback
            .filter { $0 }
            .sink { [weak self] isReadyForPlayback in
                self?.viewModel.videoPlayerIsReadyForPlayback()
            }.store(in: &cancellables)
        
        videoPlayer
            .currentTime
            .sink { [weak self] currentTime in
                self?.viewModel.videoDidUpdateCurrentTime(
                    time: currentTime,
                    duration: self?.videoPlayer.duration.value ?? 0,
                    limitedDuration: self?.videoPlayer.playbackRangeDuration.value ?? 0
                )
                
                // Ideally date formatting isn't done on the view controller
                self?.trimmingView.currentTimeLabel.text = DateFormatterTool.shared.format(time: currentTime)
            }.store(in: &cancellables)
        
        videoPlayer
            .isPlaying
            .sink { [weak self] isPlaying in
                self?.viewModel.videoDidChangePlaybackState(isPlaying: isPlaying)
            }.store(in: &cancellables)
    }
}
