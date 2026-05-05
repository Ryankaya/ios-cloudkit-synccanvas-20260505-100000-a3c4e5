import SwiftUI

struct ItemCardView: View {
    let item: CanvasItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: item.category.icon)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(6)
                    .background(Circle().fill(Color(hex: item.colorHex).opacity(0.6)))
                Spacer()
                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            if !item.content.isEmpty {
                Text(item.content)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(3)
            }

            Spacer(minLength: 0)

            HStack {
                Text(item.category.displayName.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text(item.modifiedAt, style: .relative)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: item.colorHex), Color(hex: item.colorHex).opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color(hex: item.colorHex).opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Color from hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int & 0xFF0000) >> 16) / 255.0
        let g = Double((int & 0x00FF00) >> 8) / 255.0
        let b = Double(int & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
