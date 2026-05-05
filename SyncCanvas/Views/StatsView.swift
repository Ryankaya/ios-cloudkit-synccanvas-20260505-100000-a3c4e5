import SwiftUI

struct StatsView: View {
    @EnvironmentObject var canvasVM: CanvasViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    totalCard
                    categoryBreakdown
                    recentActivity
                }
                .padding()
            }
            .navigationTitle("Insights")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var totalCard: some View {
        HStack(spacing: 0) {
            statCell(value: "\(canvasVM.items.count)", label: "Total Items", color: .blue)
            Divider().frame(height: 50)
            statCell(value: "\(canvasVM.items.filter { $0.isPinned }.count)", label: "Pinned", color: .orange)
            Divider().frame(height: 50)
            statCell(
                value: "\(canvasVM.items.filter { Calendar.current.isDateInToday($0.createdAt) }.count)",
                label: "Added Today",
                color: .green
            )
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private func statCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(ItemCategory.allCases) { cat in
                let count = canvasVM.itemsByCategory[cat] ?? 0
                let total = max(canvasVM.items.count, 1)
                let fraction = Double(count) / Double(total)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: cat.icon)
                            .foregroundStyle(Color(hex: cat.defaultColorHex))
                        Text(cat.displayName)
                            .font(.subheadline)
                        Spacer()
                        Text("\(count)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemFill))
                                .frame(height: 8)
                            Capsule()
                                .fill(Color(hex: cat.defaultColorHex))
                                .frame(width: geo.size.width * fraction, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private var recentActivity: some View {
        let recent = canvasVM.items
            .sorted { $0.modifiedAt > $1.modifiedAt }
            .prefix(5)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Recently Modified")
                .font(.headline)
                .padding(.horizontal, 4)

            if recent.isEmpty {
                Text("No items yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(Array(recent)) { item in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: item.colorHex))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: item.category.icon)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline.weight(.medium))
                                .lineLimit(1)
                            Text(item.modifiedAt, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
