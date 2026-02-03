//
//  View+Elevation.swift
//  Nuvia
//
//  Created on 2026-02-03.
//

import SwiftUI

// MARK: - Elevation Levels

enum ElevationLevel {
    case flat
    case raised
    case floating
    case overlay
    
    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 4
        case .floating: return 12
        case .overlay: return 24
        }
    }
    
    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 2
        case .floating: return 6
        case .overlay: return 12
        }
    }
    
    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .raised: return 0.08
        case .floating: return 0.12
        case .overlay: return 0.16
        }
    }
}

// MARK: - View Extension

extension View {
    func elevation(_ level: ElevationLevel) -> some View {
        self.shadow(
            color: .black.opacity(level.shadowOpacity),
            radius: level.shadowRadius,
            x: 0,
            y: level.shadowY
        )
    }
}
