//
//  VideoPlayer.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import AVKit
import UIKit
import Combine

protocol VideoPlayerControllable {
    /// The view in which video is played.
    var view: UIView { get }
    
    /// Readiness publisher to inform listeners of the readiness to play.
    var isReadyForPlayback: CurrentValueSubject<Bool, Never> { get }
    
    /// Is playing publisher, will receive a new value on play/pause events.
    var isPlaying: CurrentValueSubject<Bool, Never> { get }
    
    /// Whether or not watermarking is enabled
    var isWatermarkingEnabled: Bool { get }
    
    /// The duration of the asset, updated when asset duration changes.
    /// This duration may be shorter than the asset real duration due to shorter playback ranges.
    var playbackRangeDuration: CurrentValueSubject<TimeInterval, Never> { get }
    
    /// The available playback range, accounting for shorter playback windows (trimming).
    var playbackRange: Range<TimeInterval> { get }
    
    /// The duration of the asset, updated when asset duration changes.
    /// This duration is the real unbounded duration of the asset
    var duration: CurrentValueSubject<TimeInterval, Never> { get }
    
    /// The current time publisher, updated every milisecond.
    var currentTime: CurrentValueSubject<TimeInterval, Never> { get }
    
    /// Prepares an URL for playback. It will no play immediately after.
    /// `isReadyForPlayback` will be called afterwards.
    func prepare(url: URL?)
    
    /// Plays the current configured asset.
    func play()
    
    /// Pauses the current configured asset.
    func pause()
    
    /// Seeks to the given position.
    func seek(_ time: TimeInterval)
    
    /// Restarts the playback at the lower playback range.
    func restart()
    
    /// Generates an array of video thumbnails with the size provided
    func generateVideoThumbnails(
        timeIntervalBetweenImages: TimeInterval,
        imageSize: CGSize,
        completion: @escaping ([UIImage]) -> Void
    )
    
    /// Defines the starting playback range
    func setPlaybackRange(start: TimeInterval)
    
    /// Defines the ending playback range
    func setPlaybackRange(end: TimeInterval)
    
    /// Generates a video using the available playback range. Non-watermarked.
    func generateVideoFromAvailablePlaybackRange(completion: @escaping (URL?) -> Void)
    
    /// Enables or not the rendering of a watermarking overlay.
    func enableWatermarking(_ enabled: Bool)
}

class VideoPlayer: NSObject, VideoPlayerControllable {
    private let playerView: PlayerView
    private var player: AVPlayer? { playerView.player }
    private var watermarkingView: Watermarking.View?
    
    var playbackRange: Range<TimeInterval> = 0..<TimeInterval.greatestFiniteMagnitude
    var isWatermarkingEnabled: Bool { watermarkingView != nil }
    var view: UIView { playerView }
    var playbackRangeDuration: CurrentValueSubject<TimeInterval, Never> = .init(.zero)
    var duration: CurrentValueSubject<TimeInterval, Never> = .init(.zero)
    var isReadyForPlayback: CurrentValueSubject<Bool, Never> = .init(false)
    var isPlaying: CurrentValueSubject<Bool, Never> = .init(false)
    var currentTime: CurrentValueSubject<TimeInterval, Never> = .init(.zero)
    
    // MARK: - Initialisers
    init(
        playerView: PlayerView = .init()
    ) {
        self.playerView = playerView
        super.init()
    }
    
    // MARK: - Controlling the Player
    func prepare(url: URL?) {
        guard let url else { return }
        
        stop()

        playerView.player = AVPlayer(
            playerItem: AVPlayerItem(url: url)
        )
        
        configurePlayerObservers()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(_ time: TimeInterval) {
        seek(time, seekInsidePlaybackRange: true)
    }
    
    func generateVideoThumbnails(
        timeIntervalBetweenImages: TimeInterval,
        imageSize: CGSize,
        completion: @escaping ([UIImage]) -> Void
    ) {
        ThumbnailGenerator.generate(
            player: player,
            startTime: .zero,
            duration: duration.value,
            imageSize: imageSize,
            timeIntervalBetweenImages: timeIntervalBetweenImages,
            completion: { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        )
    }
    
    func restart() {
        seek(playbackRange.lowerBound)
    }
    
    func setPlaybackRange(start: TimeInterval) {
        updatePlaybackRange(start: start, end: playbackRange.upperBound)
    }
    
    func setPlaybackRange(end: TimeInterval) {
        updatePlaybackRange(start: playbackRange.lowerBound, end: end)
    }
    
    func generateVideoFromAvailablePlaybackRange(completion: @escaping (URL?) -> Void) {
        VideoExporter.exportVideo(
            player: player,
            playerView: playerView,
            watermarkingView: watermarkingView,
            playbackRange: playbackRange,
            preferredTimeScale: Constants.preferredTimeScale,
            completion: { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        )
    }
    
    func enableWatermarking(_ enabled: Bool) {
        guard enabled else {
            watermarkingView?.removeFromSuperview()
            watermarkingView = nil
            return
        }
        
        let watermarkingView = Watermarking.View()
        self.watermarkingView = watermarkingView
        
        playerView.addSubview(watermarkingView)
        watermarkingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            watermarkingView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            watermarkingView.topAnchor.constraint(equalTo: playerView.topAnchor),
            watermarkingView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),
            watermarkingView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor)
        ])
        
        watermarkingView.alpha = 0.35
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath,
              let player = object as? AVPlayer
        else { return }
        
        switch keyPath {
        case #keyPath(AVPlayer.timeControlStatus):
            timeControlStatusDidUpdate(player: player)
        case #keyPath(AVPlayer.status):
            readinessStatusDidUpdate(player: player)
        default:
            break
        }
    }
}

// MARK: - AVPlayer Observing
extension VideoPlayer {
    private func configurePlayerObservers() {
        configureTimeObserver()
        
        // Observes play/pause status
        player?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayer.timeControlStatus),
            options: .new,
            context: nil
        )
        
        // Observes readiness status
        player?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayer.status),
            options: .new,
            context: nil
        )
    }
    
    private func configureTimeObserver() {
        player?.addPeriodicTimeObserver(
            forInterval: CMTime(
                seconds: Constants.timeUpdateInterval,
                preferredTimescale: Constants.preferredTimeScale
            ),
            queue: .main,
            using: { [weak self] time in
                let updatedTime = TimeInterval(time.seconds)
                self?.currentTime.send(updatedTime)
            }
        )
    }
    
    private func timeControlStatusDidUpdate(player: AVPlayer) {
        // Update the isPlaying flag based on the concrete state of the player
        let currentlyPlaying: Bool = {
            switch player.timeControlStatus {
            case .playing:
                return true
            case .paused, .waitingToPlayAtSpecifiedRate:
                return false
            @unknown default:
                return false
            }
        }()
        
        isPlaying.send(currentlyPlaying)
    }
    
    private func readinessStatusDidUpdate(player: AVPlayer) {
        // Find the current state of the player
        let hasProperState: Bool = {
            switch player.status {
            case .readyToPlay:
                return true
            case .failed, .unknown:
                return false
            @unknown default:
                return false
            }
        }()
        
        // Whether or not the player had an error
        let hasNoError: Bool = player.error == nil
        
        // Whether or not readiness can be evaluated
        guard hasProperState && hasNoError else {
            print("VideoPlayer | Configured asset cannot play.")
            return
        }
        
        Task { @MainActor in
            // Readiness evaluated, try to find the duration of the loaded asset. It must have one in these vod-driven app.
            guard let itemDuration = try? await player.currentItem?.asset.load(.duration).seconds else {
                print("VideoPlayer | Configured asset has no duration.")
                return
            }
            
            // Stores the real asset duration, unbounded by playback ranges.
            duration.send(itemDuration)
            
            // Update the duration publisher with the current asset duration in seconds.
            playbackRangeDuration.send(itemDuration)
            
            // Notify the readiness publisher that the asset is ready for playback.
            isReadyForPlayback.send(true)
        }
    }
}

// MARK: - Helpers
extension VideoPlayer {
    private func stop() {
        playerView.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        playerView.player?.removeTimeObserver(self)
    }
    
    private func seek(_ time: TimeInterval, seekInsidePlaybackRange: Bool) {
        if seekInsidePlaybackRange, !playbackRange.contains(time) { return }
        
        player?.seek(
            to: CMTime(
                seconds: time,
                preferredTimescale: Constants.preferredTimeScale
            ),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }
    
    private func updatePlaybackRange(start: TimeInterval, end: TimeInterval) {
        let start = max(0, start)
        let end = min(end, duration.value)
        
        guard end > start else { return }
        playbackRange = start..<end
        playbackRangeDuration.send(end)
        
        if currentTime.value < start {
            seek(start, seekInsidePlaybackRange: false)
        } else if currentTime.value > end {
            seek(end, seekInsidePlaybackRange: false)
        }
    }
}

// MARK: - Constants
extension VideoPlayer {
    enum Constants {
        static let timeUpdateInterval: Double = 0.01
        static let preferredTimeScale: CMTimeScale = CMTimeScale(NSEC_PER_SEC)
    }
}
