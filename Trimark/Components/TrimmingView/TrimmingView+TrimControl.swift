//
//  TrimmingView+TrimControl.swift
//  Trimark
//
//  Created by Carlos Martins on 10/05/2023.
//

import UIKit

extension TrimmingView {
    class TrimControl: UIStackView {
        lazy var head = UILabel()
        lazy var body = UIView()
        
        // MARK: - Initialisers
        required init(leftSide: Bool) {
            super.init(frame: .zero)
            setupLayout(leftSide: leftSide)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Layouting
        private func setupLayout(leftSide: Bool) {
            axis = .vertical
            head.backgroundColor = .systemYellow
            body.backgroundColor = .systemYellow
            
            if leftSide {
                head.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else {
                head.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            }
            
            head.layer.cornerRadius = 12
            head.clipsToBounds = true
            
            body.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            body.layer.cornerRadius = 3
            body.clipsToBounds = true
            
            alignment = leftSide ? .leading : .trailing
            head.text = leftSide ? "▶" : "◀"
            head.textColor = .darkGray
            head.textAlignment = .center
            head.isUserInteractionEnabled = true
            
            alpha = 0.95
            
            addArrangedSubview(head)
            addArrangedSubview(body)
            translatesAutoresizingMaskIntoConstraints = false
            head.translatesAutoresizingMaskIntoConstraints = false
            body.translatesAutoresizingMaskIntoConstraints = false
            
            head.heightAnchor.constraint(equalToConstant: 40).isActive = true
            head.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            body.widthAnchor.constraint(equalToConstant: 5).isActive = true
        }
    }
}
