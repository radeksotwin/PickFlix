//
//  HapticsManager.swift
//  PickFlix
//
//  Created by Rdm on 17/07/2026.
//

import UIKit

class Haptics {
    static func generateImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
