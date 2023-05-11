//
//  HomeViewModelDelegateMock.swift
//  TrimarkTests
//
//  Created by Carlos Martins on 11/05/2023.
//

@testable import Trimark
import Foundation

class HomeViewModelDelegateMock: HomeViewModelDelegate {
    var playCalled: (() -> Void)?
    func play() {
        playCalled?()
    }
    
    var pausedCalled: (() -> Void)?
    func pause() {
        pausedCalled?()
    }
    
    var restartCalled: (() -> Void)?
    func restart() {
        restartCalled?()
    }
    
    var updateProgressCalled: ((TimeInterval) -> Void)?
    func updateProgress(to percentage: TimeInterval) {
        updateProgressCalled?(percentage)
    }
    
    func loadVideo(url: URL) {}
    func loadThumbnails() {}
    func prepareUi() {}
    func shareTrimmedVideo() {}
    func enableWatermarking(enabled: Bool) {}
}
