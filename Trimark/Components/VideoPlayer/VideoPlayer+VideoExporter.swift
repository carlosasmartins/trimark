//
//  VideoPlayer+VideoExporter.swift
//  Trimark
//
//  Created by Carlos Martins on 11/05/2023.
//

import Foundation
import AVKit
import MetalKit

extension VideoPlayer {
    enum VideoExporter {
        /// Exports the trimmed video *without watermarking* 💔
        ///
        /// Tried multiple ways  to export with watermarking using things like `AVComposition` and `AVVideoCompositionCoreAnimationTool`.
        /// I quickly realised that I was not going anywhere with just that. 😅
        ///
        /// I figure that the best path forward would be to use `AVAssetWritter` and start adding the texture byte data. This would be probably
        /// done in `draw(in: MTKView)` so that we could do it every frame, recording a watermark video frame by frame. AssetWriter would then give us, at a
        /// given url, the watermarking video only. However I wonder, how much time would we have to wait for the video to record? The same amount of time that
        /// the original video has?
        ///
        /// Then it would be probably the time for `AVComposition` to shine, and we would have to mix the original video track with the watermark video track with the
        /// audio track.
        ///
        /// The simpler approach would be to just record the `UIView` where all of this happens, however the original video size can be quite larger than whatever
        /// is rendered in a given `UIView`.
        ///
        /// No easy way out other than simply exporting the video in its original form, with the trimmed start and end. Maybe one day I'll do it. 👀
        static func exportVideo(
            player: AVPlayer?,
            playerView: UIView,
            watermarkingView: Watermarking.View?,
            playbackRange: Range<TimeInterval>,
            preferredTimeScale: CMTimeScale,
            completion: @escaping (URL?) -> Void
        ) {
            guard let asset = player?.currentItem?.asset
            else {
                completion(nil)
                return
            }
            
            // An url to a temporary folder since the share panel can then allow you
            // to do whatever you want.
            let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appending(component: "movie")
                .appendingPathExtension(for: .quickTimeMovie)
            
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                completion(nil)
            }
            
            // Make a time range for exporting based on the trimmed choices
            let exportRange = CMTimeRange(
                start: CMTime(
                    seconds: playbackRange.lowerBound,
                    preferredTimescale: Constants.preferredTimeScale
                ),
                end: CMTime(
                    seconds: playbackRange.upperBound,
                    preferredTimescale: Constants.preferredTimeScale
                )
            )
            
            let exporter = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetHighestQuality
            )
            
            exporter?.outputURL = outputURL
            exporter?.timeRange = exportRange
            exporter?.outputFileType = .mov
            exporter?.shouldOptimizeForNetworkUse = true
            
            exporter?.exportAsynchronously {
                guard exporter?.error == nil else {
                    print("VideoPlayer | Error while exporting \(String(describing: exporter?.error?.localizedDescription))")
                    completion(nil)
                    return
                }
                
                completion(outputURL)
            }
        }
    }
}
