import Foundation

enum ItemCategory: String, CaseIterable, Identifiable, Codable {
    case note = "note"
    case idea = "idea"
    case task = "task"
    case bookmark = "bookmark"
    case quote = "quote"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .note: return "Note"
        case .idea: return "Idea"
        case .task: return "Task"
        case .bookmark: return "Bookmark"
        case .quote: return "Quote"
        }
    }

    var icon: String {
        switch self {
        case .note: return "note.text"
        case .idea: return "lightbulb.fill"
        case .task: return "checkmark.circle.fill"
        case .bookmark: return "bookmark.fill"
        case .quote: return "quote.bubble.fill"
        }
    }

    var defaultColorHex: String {
        switch self {
        case .note: return "#4ECDC4"
        case .idea: return "#FFE66D"
        case .task: return "#FF6B6B"
        case .bookmark: return "#A8E6CF"
        case .quote: return "#C9B1FF"
        }
    }
}
