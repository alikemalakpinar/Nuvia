import Foundation

// MARK: - Project Provider Protocol
/// Protocol for accessing the current project - implemented by DataManager
/// Separated into its own file to ensure proper compilation order

@MainActor
public protocol ProjectProvider: AnyObject {
    var currentProject: WeddingProject? { get }
}
