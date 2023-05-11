//
//  Home.ViewController+TrimmingViewDelegate.swift
//  Trimark
//
//  Created by Carlos Martins on 09/05/2023.
//

import UIKit

extension Home.ViewController: TrimmingViewDelegate {
    func trimmingViewDidReceiveInteraction() {
        viewModel.pauseActionTriggered()
    }
    
    func trimmingViewDidMoveTimeControlToPercentage(_ percentage: CGFloat) {
        // This should've went to the view model.
        videoPlayer.seek(videoPlayer.duration.value * TimeInterval(percentage))
    }
    
    func trimmingViewDidMoveLeftSideTrimControlToPercentage(percentage: CGFloat) {
        let time = videoPlayer.duration.value * TimeInterval(percentage)
        videoPlayer.setPlaybackRange(start: time)
        
        // Ideally date formatting isn't done on the view controller
        trimmingView.leftSideLabel.text = DateFormatterTool.shared.format(time: videoPlayer.playbackRange.lowerBound)
    }
    
    func trimmingViewDidMoveRightSideTrimControlToPercentage(percentage: CGFloat) {
        let time = videoPlayer.duration.value * TimeInterval(percentage)
        videoPlayer.setPlaybackRange(end: time)
        
        // Ideally date formatting isn't done on the view controller
        trimmingView.rightSideLabel.text = DateFormatterTool.shared.format(time: videoPlayer.playbackRange.upperBound)
    }
}
