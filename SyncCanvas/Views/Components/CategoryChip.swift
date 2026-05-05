import SwiftUI

struct CategoryChip: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(isSelected ? .white.opacity(0.3) : Color(.systemFill)))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule().fill(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
