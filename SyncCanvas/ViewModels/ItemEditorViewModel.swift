import Foundation

@MainActor
final class ItemEditorViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedCategory: ItemCategory = .note
    @Published var isLoading = false

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var characterCount: Int { content.count }
    var titleCharacterCount: Int { title.count }
    static let titleLimit = 80
    static let contentLimit = 500

    var isTitleAtLimit: Bool { titleCharacterCount >= Self.titleLimit }
    var isContentAtLimit: Bool { characterCount >= Self.contentLimit }

    func configure(from item: CanvasItem) {
        title = item.title
        content = item.content
        selectedCategory = item.category
    }

    func reset() {
        title = ""
        content = ""
        selectedCategory = .note
        isLoading = false
    }
}
