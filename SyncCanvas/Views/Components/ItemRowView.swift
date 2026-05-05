import SwiftUI

struct ItemRowView: View {
    let item: CanvasItem

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: item.colorHex))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: item.category.icon)
                        .foregroundStyle(.white)
                        .font(.headline)
                }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                if !item.content.isEmpty {
                    Text(item.content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.category.displayName)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color(hex: item.colorHex).opacity(0.2)))
                    .foregroundStyle(Color(hex: item.colorHex))
                Text(item.modifiedAt, style: .relative)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
