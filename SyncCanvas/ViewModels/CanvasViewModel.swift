import Foundation
import CloudKit
import Combine

@MainActor
final class CanvasViewModel: ObservableObject {

    // MARK: - Published state

    @Published private(set) var items: [CanvasItem] = []
    @Published private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published private(set) var isSyncing = false
    @Published var activeError: CloudKitError?
    @Published var showError = false
    @Published var searchQuery = ""
    @Published var selectedFilter: ItemCategory? = nil

    // MARK: - Private

    private let container = CKContainer(identifier: "iCloud.com.ryankaya.synccanvas")
    private var database: CKDatabase { container.privateCloudDatabase }
    private var cancellables = Set<AnyCancellable>()
    private let subscriptionID = "ck-canvas-items-v1"

    // MARK: - Computed

    var filteredItems: [CanvasItem] {
        var result = items
        if let filter = selectedFilter {
            result = result.filter { $0.category == filter }
        }
        if !searchQuery.isEmpty {
            let q = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(q) || $0.content.lowercased().contains(q)
            }
        }
        return result.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
            return lhs.modifiedAt > rhs.modifiedAt
        }
    }

    var itemsByCategory: [ItemCategory: Int] {
        Dictionary(grouping: items, by: { $0.category }).mapValues { $0.count }
    }

    var syncStatusText: String {
        if isSyncing { return "Syncing…" }
        switch accountStatus {
        case .available: return "iCloud Active"
        case .noAccount: return "No iCloud Account"
        case .restricted: return "Restricted"
        case .temporarilyUnavailable: return "Temporarily Unavailable"
        case .couldNotDetermine: return "Checking iCloud…"
        @unknown default: return "Unknown"
        }
    }

    var syncStatusIcon: String {
        if isSyncing { return "arrow.triangle.2.circlepath.icloud" }
        switch accountStatus {
        case .available: return "checkmark.icloud.fill"
        case .noAccount, .restricted: return "icloud.slash.fill"
        case .temporarilyUnavailable: return "exclamationmark.icloud.fill"
        default: return "icloud.fill"
        }
    }

    var syncStatusColor: String {
        switch accountStatus {
        case .available: return "green"
        case .noAccount, .restricted: return "red"
        case .temporarilyUnavailable: return "orange"
        default: return "gray"
        }
    }

    // MARK: - Init

    init() {
        checkAccountStatus()
        observeAccountChanges()
    }

    // MARK: - Account

    func checkAccountStatus() {
        Task {
            do {
                let status = try await container.accountStatus()
                accountStatus = status
                if status == .available {
                    await fetchItems()
                    await setupSubscription()
                }
            } catch {
                accountStatus = .couldNotDetermine
            }
        }
    }

    private func observeAccountChanges() {
        NotificationCenter.default.publisher(for: .CKAccountChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkAccountStatus()
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    func fetchItems() async {
        guard accountStatus == .available else { return }
        isSyncing = true
        defer { isSyncing = false }

        let query = CKQuery(
            recordType: CanvasItem.recordType,
            predicate: NSPredicate(value: true)
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "modificationDate", ascending: false)
        ]

        do {
            let (matchResults, _) = try await database.records(matching: query, resultsLimit: 200)
            let fetched: [CanvasItem] = matchResults.compactMap { _, result in
                guard let record = try? result.get() else { return nil }
                return CanvasItem(from: record)
            }
            items = fetched
        } catch {
            presentError(.fetchFailed(error))
        }
    }

    func fetchItemsByCategory(_ category: ItemCategory) async {
        guard accountStatus == .available else { return }
        isSyncing = true
        defer { isSyncing = false }

        let predicate = NSPredicate(format: "category == %@", category.rawValue)
        let query = CKQuery(recordType: CanvasItem.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

        do {
            let (matchResults, _) = try await database.records(matching: query)
            let fetched: [CanvasItem] = matchResults.compactMap { _, result in
                guard let record = try? result.get() else { return nil }
                return CanvasItem(from: record)
            }
            // Merge fetched into existing items
            var updated = items.filter { $0.category != category }
            updated.append(contentsOf: fetched)
            items = updated
        } catch {
            presentError(.fetchFailed(error))
        }
    }

    // MARK: - Create

    func createItem(title: String, content: String, category: ItemCategory) async {
        guard accountStatus == .available else {
            presentError(.notAuthenticated)
            return
        }
        isSyncing = true
        defer { isSyncing = false }

        let record = CKRecord(recordType: CanvasItem.recordType)
        record["title"] = title as CKRecordValue
        record["content"] = content as CKRecordValue
        record["category"] = category.rawValue as CKRecordValue
        record["colorHex"] = category.defaultColorHex as CKRecordValue
        record["isPinned"] = 0 as CKRecordValue

        do {
            let saved = try await database.save(record)
            let newItem = CanvasItem(from: saved)
            items.insert(newItem, at: 0)
        } catch {
            presentError(.saveFailed(error))
        }
    }

    // MARK: - Update

    func updateItem(_ item: CanvasItem) async {
        guard accountStatus == .available else { return }
        isSyncing = true
        defer { isSyncing = false }

        do {
            // Fetch the latest version before modifying to avoid conflicts
            let existingRecord = try await database.record(for: item.id)
            let updated = item.applying(to: existingRecord)
            let saved = try await database.save(updated)
            let updatedItem = CanvasItem(from: saved)
            if let idx = items.firstIndex(where: { $0.id == updatedItem.id }) {
                items[idx] = updatedItem
            }
        } catch {
            presentError(.saveFailed(error))
        }
    }

    func togglePin(_ item: CanvasItem) async {
        var mutable = item
        mutable.isPinned.toggle()
        await updateItem(mutable)
    }

    // MARK: - Delete

    func deleteItem(_ item: CanvasItem) async {
        guard accountStatus == .available else { return }
        isSyncing = true
        defer { isSyncing = false }

        do {
            try await database.deleteRecord(withID: item.id)
            items.removeAll { $0.id == item.id }
        } catch {
            presentError(.deleteFailed(error))
        }
    }

    func deleteItems(at offsets: IndexSet, in list: [CanvasItem]) async {
        let toDelete = offsets.map { list[$0] }
        for item in toDelete {
            await deleteItem(item)
        }
    }

    // MARK: - Subscriptions

    private func setupSubscription() async {
        let predicate = NSPredicate(value: true)
        let sub = CKQuerySubscription(
            recordType: CanvasItem.recordType,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        info.desiredKeys = ["title", "category"]
        sub.notificationInfo = info

        do {
            _ = try await database.save(sub)
        } catch let ckError as CKError where ckError.code == .serverRejectedRequest {
            // Subscription already exists — this is expected on subsequent launches
        } catch {
            presentError(.subscriptionSetupFailed(error))
        }
    }

    // MARK: - Remote notification handling

    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        guard notification?.subscriptionID == subscriptionID else { return }
        Task { await fetchItems() }
    }

    // MARK: - Helpers

    private func presentError(_ error: CloudKitError) {
        activeError = error
        showError = true
    }
}
