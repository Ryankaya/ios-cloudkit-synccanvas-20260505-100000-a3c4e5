import SwiftUI

@main
struct SyncCanvasApp: App {
    @StateObject private var canvasVM = CanvasViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(canvasVM)
        }
    }
}
