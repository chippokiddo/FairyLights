import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    var checkForUpdates: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            SettingsHeader
            SettingsForm
        }
        .padding()
        .frame(width: 400, height: 250)
        .onAppear(perform: adjustWindowAppearance)
    }
    
    // MARK: - Header
    private var SettingsHeader: some View {
        Text("Fairy Lights Settings")
            .font(.system(size: 20, weight: .semibold, design: .default))
            .padding(.bottom, 10)
    }
    
    // MARK: - Settings Form
    private var SettingsForm: some View {
        Form {
            // Update settings section
            updateSection
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Update Section
    private var updateSection: some View {
        Section {
            Toggle("Check for Updates Automatically", isOn: $appState.checkForUpdatesAutomatically)
            
            if appState.checkForUpdatesAutomatically {
                Text("Updates will be checked once a day.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Spacer()
                Button(action: {
                    checkForUpdates()
                }) {
                    if appState.isCheckingForUpdates {
                        HStack(spacing: 5) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Checking...")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .regular))
                            Text("Check for Updates")
                                .font(.system(size: 13, weight: .regular))
                        }
                    }
                }
                .buttonStyle(.borderless)
                .disabled(appState.isCheckingForUpdates)
                Spacer()
            }
        }
    }
    
    // MARK: - Window Adjustment
    private func adjustWindowAppearance() {
        if let window = NSApp.windows.first(where: { $0.title == "Settings" }) {
            window.styleMask.remove(.miniaturizable)
            window.canHide = false
        }
    }
}
