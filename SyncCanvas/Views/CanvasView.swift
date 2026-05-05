import SwiftUI
import CloudKit

struct CanvasView: View {
    @EnvironmentObject var canvasVM: CanvasViewModel
    @StateObject private var editorVM = ItemEditorViewModel()
    @State private var showEditor = false
    @State private var editingItem: CanvasItem? = nil
    @State private var viewMode: ViewMode = .grid

    enum ViewMode: String, CaseIterable {
        case grid, list
        var icon: String { self == .grid ? "square.grid.2x2" : "list.bullet" }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterStrip
                Divider()
                contentBody
            }
            .navigationTitle("SyncCanvas")
            .searchable(text: $canvasVM.searchQuery, prompt: "Search items…")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showEditor) {
                ItemEditorView(viewModel: editorVM, editingItem: nil) { title, content, category in
                    Task { await canvasVM.createItem(title: title, content: content, category: category) }
                }
            }
            .sheet(item: $editingItem) { item in
                let vm = ItemEditorViewModel()
                let _ = { vm.configure(from: item) }()
                ItemEditorView(viewModel: vm, editingItem: item) { title, content, category in
                    var updated = item
                    updated.title = title
                    updated.content = content
                    updated.category = category
                    Task { await canvasVM.updateItem(updated) }
                }
            }
            .refreshable { await canvasVM.fetchItems() }
        }
    }

    // MARK: - Sub-views

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    count: canvasVM.items.count,
                    isSelected: canvasVM.selectedFilter == nil
                ) { canvasVM.selectedFilter = nil }

                ForEach(ItemCategory.allCases) { cat in
                    CategoryChip(
                        title: cat.displayName,
                        icon: cat.icon,
                        count: canvasVM.itemsByCategory[cat] ?? 0,
                        isSelected: canvasVM.selectedFilter == cat
                    ) {
                        canvasVM.selectedFilter = (canvasVM.selectedFilter == cat) ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var contentBody: some View {
        if canvasVM.filteredItems.isEmpty {
            emptyState
        } else {
            switch viewMode {
            case .grid: gridView
            case .list: listView
            }
        }
    }

    private var gridView: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(canvasVM.filteredItems) { item in
                    ItemCardView(item: item)
                        .onTapGesture { editingItem = item }
                        .contextMenu { itemContextMenu(for: item) }
                }
            }
            .padding(16)
        }
    }

    private var listView: some View {
        List {
            ForEach(canvasVM.filteredItems) { item in
                ItemRowView(item: item)
                    .onTapGesture { editingItem = item }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await canvasVM.deleteItem(item) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            Task { await canvasVM.togglePin(item) }
                        } label: {
                            Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash" : "pin.fill")
                        }
                        .tint(.orange)
                    }
            }
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.4))
            VStack(spacing: 6) {
                Text(canvasVM.accountStatus == .available ? "Canvas is Empty" : "Sign in to iCloud")
                    .font(.title2.weight(.semibold))
                Text(canvasVM.accountStatus == .available
                     ? "Tap + to add items.\nThey sync instantly to all your devices."
                     : "Go to Settings › [Your Name] and sign in to iCloud to start syncing.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if canvasVM.accountStatus == .available {
                Button { showEditor = true } label: {
                    Label("Add First Item", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding(32)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            SyncIndicator()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 12) {
                Picker("View", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.icon).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 80)

                Button {
                    editorVM.reset()
                    showEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .disabled(canvasVM.accountStatus != .available)
            }
        }
    }

    @ViewBuilder
    private func itemContextMenu(for item: CanvasItem) -> some View {
        Button {
            editingItem = item
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        Button {
            Task { await canvasVM.togglePin(item) }
        } label: {
            Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash" : "pin.fill")
        }
        Divider()
        Button(role: .destructive) {
            Task { await canvasVM.deleteItem(item) }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
