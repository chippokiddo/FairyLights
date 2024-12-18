import SwiftUI

@MainActor
class AppState: ObservableObject {
    @AppStorage("checkForUpdatesAutomatically") var checkForUpdatesAutomatically: Bool = false
    
    @Published var isCheckingForUpdates: Bool = false
    
}
