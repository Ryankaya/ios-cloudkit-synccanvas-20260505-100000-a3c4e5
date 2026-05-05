import Foundation
import CloudKit

struct CanvasItem: Identifiable, Equatable {
    static let recordType = "CanvasItem"

    let id: CKRecord.ID
    var title: String
    var content: String
    var category: ItemCategory
    var colorHex: String
    var isPinned: Bool
    var createdAt: Date
    var modifiedAt: Date

    init(from record: CKRecord) {
        self.id = record.recordID
        self.title = record["title"] as? String ?? "Untitled"
        self.content = record["content"] as? String ?? ""
        self.category = ItemCategory(rawValue: record["category"] as? String ?? "") ?? .note
        self.colorHex = record["colorHex"] as? String ?? ItemCategory.note.defaultColorHex
        self.isPinned = (record["isPinned"] as? Int ?? 0) == 1
        self.createdAt = record.creationDate ?? Date()
        self.modifiedAt = record.modificationDate ?? Date()
    }

    func applying(to record: CKRecord) -> CKRecord {
        record["title"] = title as CKRecordValue
        record["content"] = content as CKRecordValue
        record["category"] = category.rawValue as CKRecordValue
        record["colorHex"] = colorHex as CKRecordValue
        record["isPinned"] = (isPinned ? 1 : 0) as CKRecordValue
        return record
    }

    static func == (lhs: CanvasItem, rhs: CanvasItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.category == rhs.category &&
        lhs.isPinned == rhs.isPinned
    }
}
