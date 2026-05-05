import SwiftUI

struct ItemEditorView: View {
    @ObservedObject var viewModel: ItemEditorViewModel
    let editingItem: CanvasItem?
    let onSave: (String, String, ItemCategory) -> Void
    @Environment(\.dismiss) private var dismiss

    var isEditing: Bool { editingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    HStack {
                        TextField("Enter a title…", text: $viewModel.title)
                            .onChange(of: viewModel.title) { _, new in
                                if new.count > ItemEditorViewModel.titleLimit {
                                    viewModel.title = String(new.prefix(ItemEditorViewModel.titleLimit))
                                }
                            }
                        Text("\(viewModel.titleCharacterCount)/\(ItemEditorViewModel.titleLimit)")
                            .font(.caption2)
                            .foregroundStyle(viewModel.isTitleAtLimit ? .red : .secondary)
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }

                Section("Content") {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 100)
                        .onChange(of: viewModel.content) { _, new in
                            if new.count > ItemEditorViewModel.contentLimit {
                                viewModel.content = String(new.prefix(ItemEditorViewModel.contentLimit))
                            }
                        }
                    HStack {
                        Spacer()
                        Text("\(viewModel.characterCount)/\(ItemEditorViewModel.contentLimit)")
                            .font(.caption2)
                            .foregroundStyle(viewModel.isContentAtLimit ? .red : .secondary)
                    }
                }

                Section {
                    categoryPreview
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        onSave(viewModel.title, viewModel.content, viewModel.selectedCategory)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave || viewModel.isLoading)
                }
            }
        }
    }

    private var categoryPreview: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: viewModel.selectedCategory.defaultColorHex))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: viewModel.selectedCategory.icon)
                        .foregroundStyle(.white)
                        .font(.headline)
                }
            VStack(alignment: .leading) {
                Text(viewModel.title.isEmpty ? "Preview Title" : viewModel.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(viewModel.title.isEmpty ? .secondary : .primary)
                Text(viewModel.selectedCategory.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
