//
//  FormattingUtils.swift
//  Trimark
//
//  Created by Carlos Martins on 10/05/2023.
//

import Foundation

class DateFormatterTool {
    static var shared: DateFormatterTool = .init()
    
    private let hourMinuteSecondFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }()
    
    func format(time: TimeInterval) -> String {
        hourMinuteSecondFormatter.string(from: time) ?? ""
    }
}
