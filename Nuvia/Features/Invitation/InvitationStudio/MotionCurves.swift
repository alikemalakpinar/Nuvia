//
//  MotionCurves.swift
//  Nuvia
//
//  Created on 2026-02-03.
//

import SwiftUI

/// Standardized animation curves for consistent motion throughout the app
enum MotionCurves {
    /// Quick animation for instant feedback (0.25s)
    static let quick = Animation.smooth(duration: 0.25)
    
    /// Standard smooth animation (0.35s)
    static let smooth = Animation.smooth(duration: 0.35)
    
    /// Bouncy animation for playful interactions (0.5s)
    static let bouncy = Animation.bouncy(duration: 0.5)
    
    /// Instant animation for immediate changes (0.15s)
    static let instant = Animation.easeInOut(duration: 0.15)
    
    /// Slow animation for dramatic effects (0.6s)
    static let slow = Animation.smooth(duration: 0.6)
    
    /// Spring animation with default parameters
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    /// Snappy animation for crisp interactions
    static let snappy = Animation.snappy(duration: 0.3)
}
