import SwiftUI

struct ContentView: View {
    @EnvironmentObject var canvasVM: CanvasViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CanvasView()
                .tabItem { Label("Canvas", systemImage: "rectangle.stack.fill") }
                .tag(0)

            StatsView()
                .tabItem { Label("Insights", systemImage: "chart.pie.fill") }
                .tag(1)

            AccountStatusView()
                .tabItem { Label("iCloud", systemImage: "icloud.fill") }
                .tag(2)
        }
        .alert("Error", isPresented: $canvasVM.showError) {
            Button("OK", role: .cancel) {}
            if canvasVM.activeError?.isRetryable == true {
                Button("Retry") {
                    Task { await canvasVM.fetchItems() }
                }
            }
        } message: {
            Text(canvasVM.activeError?.localizedDescription ?? "An unknown error occurred.")
        }
    }
}
