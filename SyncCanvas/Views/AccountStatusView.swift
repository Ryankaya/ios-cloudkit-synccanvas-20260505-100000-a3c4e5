import SwiftUI
import CloudKit

struct AccountStatusView: View {
    @EnvironmentObject var canvasVM: CanvasViewModel

    var statusColor: Color {
        switch canvasVM.accountStatus {
        case .available: return .green
        case .noAccount, .restricted: return .red
        case .temporarilyUnavailable: return .orange
        default: return .gray
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Status card
                Section {
                    statusCard
                }

                // Stats
                Section("Item Summary") {
                    ForEach(ItemCategory.allCases) { cat in
                        HStack {
                            Image(systemName: cat.icon)
                                .foregroundStyle(Color(hex: cat.defaultColorHex))
                                .frame(width: 24)
                            Text(cat.displayName)
                            Spacer()
                            Text("\(canvasVM.itemsByCategory[cat] ?? 0)")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    HStack {
                        Image(systemName: "tray.2.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 24)
                        Text("Total")
                        Spacer()
                        Text("\(canvasVM.items.count)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                // CloudKit container info
                Section("CloudKit Info") {
                    LabeledContent("Container", value: "iCloud.com.ryankaya.synccanvas")
                    LabeledContent("Database", value: "Private")
                    LabeledContent("Record Type", value: "CanvasItem")
                    LabeledContent("Subscription", value: "Active (push)")
                }

                Section {
                    Button {
                        Task { await canvasVM.fetchItems() }
                    } label: {
                        HStack {
                            if canvasVM.isSyncing {
                                ProgressView().scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath.icloud")
                            }
                            Text("Refresh from iCloud")
                        }
                    }
                    .disabled(canvasVM.isSyncing || canvasVM.accountStatus != .available)

                    Button {
                        canvasVM.checkAccountStatus()
                    } label: {
                        Label("Recheck Account Status", systemImage: "person.icloud")
                    }
                }
            }
            .navigationTitle("iCloud Status")
        }
    }

    private var statusCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: canvasVM.syncStatusIcon)
                    .font(.system(size: 32))
                    .foregroundStyle(statusColor)
            }
            VStack(spacing: 4) {
                Text(canvasVM.syncStatusText)
                    .font(.title3.weight(.semibold))
                Text(statusDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var statusDescription: String {
        switch canvasVM.accountStatus {
        case .available:
            return "Items sync automatically across all your devices signed into iCloud."
        case .noAccount:
            return "Go to Settings › [Your Name] to sign in to iCloud."
        case .restricted:
            return "iCloud access is restricted on this device."
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable. Please try again later."
        case .couldNotDetermine:
            return "Checking your iCloud account status…"
        @unknown default:
            return "Unknown account status."
        }
    }
}
