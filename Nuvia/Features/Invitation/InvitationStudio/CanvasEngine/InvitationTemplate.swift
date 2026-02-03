import Foundation

public enum InvitationTemplate: String, CaseIterable, Codable {
    case minimal
    case floral
    case modern
    case luxury
    case classic
    case romantic
    
    public var name: String {
        switch self {
        case .minimal: return "Minimal"
        case .floral: return "Floral"
        case .modern: return "Modern"
        case .luxury: return "Luxury"
        case .classic: return "Classic"
        case .romantic: return "Romantic"
        }
    }
}
