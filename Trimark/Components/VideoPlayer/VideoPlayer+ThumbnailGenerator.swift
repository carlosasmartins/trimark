//
//  VideoPlayer+ThumbnailGenerator.swift
//  Trimark
//
//  Created by Carlos Martins on 09/05/2023.
//

import AVKit
import UIKit

extension VideoPlayer {
    enum ThumbnailGenerator {
        /// Generates a number of thumbnails given a interval between images and the amount of time the asset has.
        static func generate(
            player: AVPlayer?,
            startTime: TimeInterval,
            duration: TimeInterval,
            imageSize: CGSize,
            timeIntervalBetweenImages: TimeInterval,
            completion: @escaping ([UIImage]) -> Void
        ) {
            guard let asset = player?.currentItem?.asset else {
                completion([])
                return
            }
            
            // Offload the generation to an utility task
            Task {
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                
                // Make sure the image is in the correct orientation
                imageGenerator.appliesPreferredTrackTransform = true
                imageGenerator.maximumSize = imageSize
                imageGenerator.apertureMode = .productionAperture
                
                // Define the interval for thumbnail generation
                let timePeriodsForThumbnailGeneration = makeTimePeriodsForThumbnailGeneration(
                    startTime: startTime,
                    duration: duration,
                    intervalBetweenImages: timeIntervalBetweenImages
                )

                // Using images(for:) due to being recommended usage in swift.
                let result = imageGenerator.images(for: timePeriodsForThumbnailGeneration)
                var thumbnails: [UIImage] = []

                // Creates an async iterator and iterates over every single image
                var iterator = result.makeAsyncIterator()
                while let nextThumbnail = await iterator.next() {
                    guard let image = try? nextThumbnail.image else {
                        print("No thumbnail generated")
                        continue
                    }

                    thumbnails.append(UIImage(cgImage: image))
                }

                completion(thumbnails)
            }
        }
        
        /// Makes an array of time intervals contained inside the given [start, duration] interval.
        private static func makeTimePeriodsForThumbnailGeneration(
            startTime: TimeInterval,
            duration: TimeInterval,
            intervalBetweenImages: TimeInterval
        ) -> [CMTime] {
            guard !startTime.isNaN && !duration.isNaN else {
                return []
            }
            
            var periods: [CMTime] = []
            for time in stride(from: startTime, through: duration, by: intervalBetweenImages) {
                periods.append(CMTime(seconds: time.rounded(), preferredTimescale: 1))
            }
            
            return periods
        }
    }
}
