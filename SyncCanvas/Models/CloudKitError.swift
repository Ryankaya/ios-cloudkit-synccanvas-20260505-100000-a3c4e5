import Foundation

enum CloudKitError: LocalizedError {
    case notAuthenticated
    case networkUnavailable
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case subscriptionSetupFailed(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "iCloud account not found. Please sign in to iCloud in Settings."
        case .networkUnavailable:
            return "No network. Changes will sync when connectivity is restored."
        case .saveFailed(let e):
            return "Failed to save: \(e.localizedDescription)"
        case .fetchFailed(let e):
            return "Failed to fetch items: \(e.localizedDescription)"
        case .deleteFailed(let e):
            return "Failed to delete: \(e.localizedDescription)"
        case .subscriptionSetupFailed(let e):
            return "Subscription setup failed: \(e.localizedDescription)"
        case .unknown(let e):
            return e.localizedDescription
        }
    }

    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .fetchFailed: return true
        default: return false
        }
    }
}
