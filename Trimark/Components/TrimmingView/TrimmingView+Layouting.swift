//
//  TrimmingView+Layouting.swift
//  Trimark
//
//  Created by Carlos Martins on 10/05/2023.
//

import UIKit

extension TrimmingView {
    func setupView() {
        backgroundColor = .lightGray
        setupHorizontalStack()
        setupTimeControl()
        setupTimeLabel()
        setupTrimControls()
        setupBeatifulCorners()
        setupGestures()
    }
    
    // MARK: - Horizontal Stack / Thumbnail Previewer
    private func setupHorizontalStack() {
        addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Style it
        horizontalStack.backgroundColor = .black
        
        // Bound the horizontal stack to the superview with some margins
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            trailingAnchor.constraint(equalTo: horizontalStack.trailingAnchor, constant: 40),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 25)
        ])
    }
    
    // MARK: - Time Control Layouting
    private func setupTimeControl() {
        addSubview(currentTimeControl)
        currentTimeControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the constraint that will be used to control the distance
        // between the view and the left edge.
        let controllingConstraint = currentTimeControl.leadingAnchor.constraint(
            equalTo: horizontalStack.leadingAnchor
        )
        
        // Store its reference for later manipulation
        self.currentTimeControlConstraint = controllingConstraint
        
        // Activate constraints
        NSLayoutConstraint.activate([
            currentTimeControl.widthAnchor.constraint(equalToConstant: 6),
            currentTimeControl.topAnchor.constraint(equalTo: horizontalStack.topAnchor),
            currentTimeControl.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor),
            controllingConstraint
        ])
        
        // Style the view
        currentTimeControl.backgroundColor = .red
        currentTimeControl.layer.cornerRadius = 3
        currentTimeControl.alpha = 0.8
        
        // Initial state
        currentTimeControl.isHidden = true
        currentTimeControl.isUserInteractionEnabled = false
    }
    
    private func setupTimeLabel() {
        addSubview(currentTimeLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentTimeLabel.centerXAnchor.constraint(equalTo: currentTimeControl.centerXAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: currentTimeControl.bottomAnchor, constant: 4)
        ])
        
        // Style it
        currentTimeLabel.font = .systemFont(ofSize: 12)
        currentTimeLabel.textColor = .darkGray
        
        // Initial state
        currentTimeLabel.isHidden = true
    }
    
    // MARK: - Trim Controls Layouting
    private func setupTrimControls() {
        setupLeftSideTrimControl()
        setupRightSideTrimControl()
    }
    
    private func setupLeftSideTrimControl() {
        setupCommonTrimControlParts(
            occlusionView: leftSideOcclusionView,
            controlLabel: leftSideLabel,
            controlView: leftSideControl
        )
        
        // A constraint to control the left side trim control
        let leftSideControllingConstraint = leftSideControl.body.trailingAnchor.constraint(
            equalTo: horizontalStack.leadingAnchor
        )
        
        // Store it for later manipulation
        self.leftSideControlConstraint = leftSideControllingConstraint
        
        // Bound the components
        NSLayoutConstraint.activate([
            leftSideControllingConstraint,
            leftSideOcclusionView.leadingAnchor.constraint(equalTo: horizontalStack.leadingAnchor),
            leftSideOcclusionView.topAnchor.constraint(equalTo: horizontalStack.topAnchor),
            leftSideOcclusionView.trailingAnchor.constraint(equalTo: leftSideControl.body.trailingAnchor),
            leftSideOcclusionView.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor),
            leftSideLabel.trailingAnchor.constraint(equalTo: leftSideControl.trailingAnchor),
        ])
    }
    
    private func setupRightSideTrimControl() {
        setupCommonTrimControlParts(
            occlusionView: rightSideOcclusionView,
            controlLabel: rightSideLabel,
            controlView: rightSideControl
        )
        
        // A constraint to control the right side trim control
        let rightSideControllingConstraint = horizontalStack.trailingAnchor.constraint(
            equalTo: rightSideControl.body.leadingAnchor
        )
        
        // Store it for later manipulation
        self.rightSideControlConstraint = rightSideControllingConstraint
        
        // Bound the components
        NSLayoutConstraint.activate([
            rightSideControllingConstraint,
            rightSideOcclusionView.trailingAnchor.constraint(equalTo: horizontalStack.trailingAnchor),
            rightSideOcclusionView.topAnchor.constraint(equalTo: horizontalStack.topAnchor),
            rightSideOcclusionView.leadingAnchor.constraint(equalTo: rightSideControl.body.leadingAnchor),
            rightSideOcclusionView.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor),
            rightSideLabel.leadingAnchor.constraint(equalTo: rightSideControl.leadingAnchor),
        ])
    }
    
    private func setupCommonTrimControlParts(
        occlusionView: UIView,
        controlLabel: UILabel,
        controlView: UIView
    ) {
        // Add the left side occlusion view
        addSubview(occlusionView)
        occlusionView.translatesAutoresizingMaskIntoConstraints = false
        occlusionView.isUserInteractionEnabled = false
        
        // Style it
        occlusionView.backgroundColor = .black.withAlphaComponent(0.8)
        
        // Add the left side control & label
        addSubview(controlView)
        addSubview(controlLabel)
        controlView.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Style the label
        controlLabel.font = .systemFont(ofSize: 12)
        controlLabel.textColor = .darkGray
        
        // Initial state of control and label
        controlView.isHidden = true
        controlLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            // The label in relation to the control
            controlView.topAnchor.constraint(equalTo: controlLabel.bottomAnchor, constant: 5),
            
            // The control in relation to the horizontal stack
            controlView.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor),
            controlView.widthAnchor.constraint(equalToConstant: 40),
            controlView.heightAnchor.constraint(
                equalTo: horizontalStack.heightAnchor, multiplier: 1.0, constant: 40
            )
        ])
    }
    
    private func setupBeatifulCorners() {
        horizontalStack.layer.cornerRadius = 3
        horizontalStack.layer.masksToBounds = true
        
        leftSideOcclusionView.layer.masksToBounds = true
        leftSideOcclusionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        leftSideOcclusionView.layer.cornerRadius = 3
        
        rightSideOcclusionView.layer.masksToBounds = true
        rightSideOcclusionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        rightSideOcclusionView.layer.cornerRadius = 3
    }
    
    // MARK: - Gestures
    private func setupGestures() {
        // Scrubbing gesture on the horizontal stack
        addGestureRecognizer(currentTimeControlPanGesture)
        
        // Trimming gestures on the control heads
        leftSideControl.head.addGestureRecognizer(leftSideControlPanGesture)
        rightSideControl.head.addGestureRecognizer(rightSideControlPanGesture)
    }
}
