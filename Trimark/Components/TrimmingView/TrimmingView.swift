//
//  TrimmingView.swift
//  Trimark
//
//  Created by Carlos Martins on 09/05/2023.
//

import UIKit

protocol TrimmingViewDelegate: AnyObject {
    func trimmingViewDidReceiveInteraction()
    func trimmingViewDidMoveTimeControlToPercentage(_ percentage: CGFloat)
    func trimmingViewDidMoveLeftSideTrimControlToPercentage(percentage: CGFloat)
    func trimmingViewDidMoveRightSideTrimControlToPercentage(percentage: CGFloat)
}

/// A View responsible for displaying the thumbnails, the trim controls, min/max labels and current time indicators.
class TrimmingView: UIView {
    
    // MARK: - Properties: UI Components
    /// To hold the thumbnail images and seeking gesture
    lazy var horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: Properties: UI Components - Current Time Related Views
    /// The view responsible for indicating the current position in the thumbnail view
    lazy var currentTimeControl: UIView = UIView()
    
    /// The label repsonsible for showing the current time
    private(set) lazy var currentTimeLabel = UILabel()
    
    /// A constraint for controling horizontal position of the current time control
    var currentTimeControlConstraint: NSLayoutConstraint?
    
    /// A way to scrub in the video
    lazy var currentTimeControlPanGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanTimeControl))
    
    // MARK: Properties: UI Components - Left-side trim controls
    /// The label responsible for indicating the left side trim value
    private(set) lazy var leftSideLabel: UILabel = UILabel()
    
    /// The left side trim control
    lazy var leftSideControl = TrimControl(leftSide: true)
    
    /// A view that occludes the leftside part of the thumbnails in relation to the trim control
    lazy var leftSideOcclusionView = UIView()
    
    /// A way to control the left side trim control horizontal position
    var leftSideControlConstraint: NSLayoutConstraint?
    
    /// The gesture to control the trim control
    lazy var leftSideControlPanGesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(didPanLeftSideControl)
    )
    
    // MARK: Properties: UI Components - Left-side trim controls
    /// The label responsible for indicating the right side trim value
    private(set) lazy var rightSideLabel = UILabel()
    
    /// The right side trim control
    lazy var rightSideControl = TrimControl(leftSide: false)
    
    /// A view that occludes the rightside part of the thumbnails in relation to the trim control
    lazy var rightSideOcclusionView = UIView()
    
    /// A way to control the right side trim control horizontal position
    var rightSideControlConstraint: NSLayoutConstraint?
    
    /// The gesture to control the trim control
    lazy var rightSideControlPanGesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(didPanRightSideControl)
    )
    
    // MARK: - Properties: State
    /// A bridge to someone that is holding this view
    weak var delegate: TrimmingViewDelegate?
    
    // MARK: - Initialisers
    required init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func animateViewToPosition(constraint: NSLayoutConstraint?, position: CGFloat) {
        constraint?.constant = position
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState
        ) { [weak self] in
            self?.setNeedsLayout()
        }
    }
}

// MARK: - Available Interface to outside of the view
extension TrimmingView {
    /// Returns the available size for rendering thumbnails. Useful in calculating how many we can fit.
    func availableSizeForThumbnails() -> CGSize {
        horizontalStack.bounds.size
    }
    
    /// Draws an array of thumbnails at a given image size.
    func drawThumbnails(
        _ images: [UIImage],
        imageSize: CGSize
    ) {
        horizontalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for image in images {
            let image = UIImageView(image: image)
            image.contentMode = .center
            horizontalStack.addArrangedSubview(image)
        }
        
        // Make visible all the thumbnail dependent views
        currentTimeLabel.isHidden = false
        currentTimeControl.isHidden = false
        leftSideControl.isHidden = false
        leftSideLabel.isHidden = false
        rightSideLabel.isHidden = false
        rightSideControl.isHidden = false
    }
    
    /// Updates the current time position
    func progressPercentageDidUpdate(_ percentage: Double) {
        let position = horizontalStack.bounds.width * CGFloat(percentage)
        animateViewToPosition(constraint: currentTimeControlConstraint, position: position)
    }
}

// MARK: - Scrubbing Control Gesture
extension TrimmingView {
    // MARK: - Current Time Update
    @objc private func didPanTimeControl(_ recognizer: UIPanGestureRecognizer) {
        delegate?.trimmingViewDidReceiveInteraction()
        
        switch recognizer.state {
        case .began, .changed:
            let position = recognizer.location(in: horizontalStack).x
            let percentage = position / horizontalStack.bounds.width
            
            delegate?.trimmingViewDidMoveTimeControlToPercentage(percentage)
        default:
            break
        }
    }
}

// MARK: - Trimming Controls Gestures
extension TrimmingView {
    @objc private func didPanLeftSideControl(_ recognizer: UIPanGestureRecognizer) {
        delegate?.trimmingViewDidReceiveInteraction()
        
        switch recognizer.state {
        case .began, .changed:
            let gesturePosition = recognizer.location(in: horizontalStack).x
            
            // As to not overlap the rightside indicator
            let maxConstraintPosition = -horizontalStack.frame.minX + rightSideControl.frame.maxX - (rightSideControl.head.bounds.width * 2)
            let constraintPosition = min(max(0, gesturePosition), maxConstraintPosition)
            
            // A percentage of the "scrub bar" that was moved.
            let percentage = constraintPosition / horizontalStack.bounds.width
            
            animateViewToPosition(
                constraint: leftSideControlConstraint,
                position: constraintPosition
            )
            
            delegate?.trimmingViewDidMoveLeftSideTrimControlToPercentage(percentage: percentage)
        default:
            break
        }
    }
    
    @objc private func didPanRightSideControl(_ recognizer: UIPanGestureRecognizer) {
        delegate?.trimmingViewDidReceiveInteraction()
        
        switch recognizer.state {
        case .began, .changed:
            let gesturePosition = recognizer.location(in: horizontalStack).x
            
            // As to not overlap the leftside indicator
            let minConstraintPosition = horizontalStack.bounds.width - leftSideControl.frame.maxX
            let constraintPosition = min(max(0, horizontalStack.bounds.width - gesturePosition), minConstraintPosition)
            
            let percentage = 1 - ((constraintPosition + rightSideControl.body.bounds.width) / horizontalStack.bounds.width)
            
            animateViewToPosition(
                constraint: rightSideControlConstraint,
                position: constraintPosition
            )
            
            delegate?.trimmingViewDidMoveRightSideTrimControlToPercentage(percentage: percentage)
        default:
            break
        }
    }
}
