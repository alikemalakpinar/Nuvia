import SwiftUI

// MARK: - Design Tokens
/// Centralized design system tokens for consistent spacing, sizing, and layout

struct DesignTokens {
    
    // MARK: - Spacing
    
    enum Spacing {
        /// 4pt spacing
        static let xxs: CGFloat = 4
        
        /// 8pt spacing
        static let xs: CGFloat = 8
        
        /// 12pt spacing
        static let sm: CGFloat = 12
        
        /// 16pt spacing
        static let md: CGFloat = 16
        
        /// 24pt spacing
        static let lg: CGFloat = 24
        
        /// 32pt spacing
        static let xl: CGFloat = 32
        
        /// 48pt spacing
        static let xxl: CGFloat = 48
        
        // MARK: - Nuvia-specific Spacing
        
        /// Standard margin for Nuvia layouts (20pt)
        static let nuviaMargin: CGFloat = 20
        
        /// Card padding (20pt)
        static let cardPadding: CGFloat = 20
        
        /// Section spacing (24pt)
        static let sectionSpacing: CGFloat = 24
        
        /// Bottom inset for scrollable content (80pt)
        static let scrollBottomInset: CGFloat = 80
    }
    
    // MARK: - Touch Targets
    
    enum Touch {
        /// Minimum comfortable touch target (44pt)
        static let comfortable: CGFloat = 44
        
        /// Standard touch target (48pt)
        static let standard: CGFloat = 48
        
        /// Large touch target (56pt)
        static let large: CGFloat = 56
    }
    
    // MARK: - Corner Radius
    
    enum Radius {
        /// Small radius (8pt)
        static let sm: CGFloat = 8
        
        /// Medium radius (12pt)
        static let md: CGFloat = 12
        
        /// Large radius (16pt)
        static let lg: CGFloat = 16
        
        /// Extra large radius (20pt)
        static let xl: CGFloat = 20
        
        /// Extra extra large radius (24pt)
        static let xxl: CGFloat = 24
        
        /// Circle/Pill radius
        static let pill: CGFloat = 999
    }
}
