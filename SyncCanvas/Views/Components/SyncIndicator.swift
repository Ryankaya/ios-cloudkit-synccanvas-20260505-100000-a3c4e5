import SwiftUI

struct SyncIndicator: View {
    @EnvironmentObject var canvasVM: CanvasViewModel

    var indicatorColor: Color {
        switch canvasVM.accountStatus {
        case .available: return canvasVM.isSyncing ? .blue : .green
        case .noAccount, .restricted: return .red
        case .temporarilyUnavailable: return .orange
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            if canvasVM.isSyncing {
                ProgressView()
                    .scaleEffect(0.7)
                    .tint(.blue)
            } else {
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 7, height: 7)
            }
            Text(canvasVM.syncStatusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .animation(.easeInOut, value: canvasVM.isSyncing)
    }
}
