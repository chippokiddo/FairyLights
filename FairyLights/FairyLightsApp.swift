import SwiftUI
import AppKit

@main
struct FairyLightsApp: App {
    @StateObject private var lightsController = LightsController()
    @StateObject private var appState = AppState()
    
    @State private var aboutWindow: NSWindow?
    @State private var settingsWindow: NSWindow?
    @State private var alertType: AlertType?

    var body: some Scene {
        MenuBarExtra {
            VStack {
                Button(lightsController.isLightsOn ? "Turn Off" : "Turn On") {
                    lightsController.toggleLights()
                }
                Divider()
                Button("Settings") {
                    showSettingsWindow()
                }
                Button("Check for Updates") {
                    checkForAppUpdates()
                }
                Button("About Fairy Lights") {
                    showAboutWindow()
                }
                Divider()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        } label: {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 16
                $0.size.width = 16 / ratio
                return $0
            }(NSImage(named: "MenuBarIcon") ?? NSImage())
            Image(nsImage: image)
                .opacity(lightsController.isLightsOn ? 1.0 : 0.35)
        }
    }
    
    // MARK: - Update Check
    private func checkForAppUpdates() {
        appState.isCheckingForUpdates = true
        Task { @MainActor in
            do {
                let (latestVersion, downloadURL) = try await fetchLatestRelease()
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                
                if isNewerVersion(latestVersion, than: currentVersion) {
                    // Show update available alert
                    showUpdateAvailableAlert(version: latestVersion, downloadURL: downloadURL)
                } else {
                    // Show no updates available alert
                    showNoUpdateAlert()
                }
            } catch {
                // Show error alert
                showErrorAlert(message: error.localizedDescription)
            }
            appState.isCheckingForUpdates = false
        }
    }
    
    // MARK: - About, Settings
    private func showAboutWindow() {
        if aboutWindow == nil {
            let hostingController = NSHostingController(rootView: AboutView())
            aboutWindow = createWindow(title: "About Fairy Lights", content: hostingController, width: 320, height: 320)
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func showSettingsWindow() {
        if settingsWindow == nil {
            let hostingController = NSHostingController(rootView: SettingsView(checkForUpdates: {
                checkForAppUpdates()
            }).environmentObject(appState))
            settingsWindow = createWindow(title: "Settings", content: hostingController, width: 400, height: 250)
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func createWindow(title: String, content: NSViewController, width: CGFloat, height: CGFloat) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.contentViewController = content
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
    
    private func showUpdateAvailableAlert(version: String, downloadURL: URL) {
        let alert = NSAlert()
        alert.messageText = "New Update Available"
        alert.informativeText = "Fairy Lights \(version) is available. Would you like to download it?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Later")

        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(downloadURL)
        }
    }

    private func showNoUpdateAlert() {
        let alert = NSAlert()
        alert.messageText = "No Updates Available"
        alert.informativeText = "You are already on the latest version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Update Check Failed"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func isNewerVersion(_ newVersion: String, than currentVersion: String) -> Bool {
        let newComponents = newVersion.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        for (new, current) in zip(newComponents, currentComponents) {
            if new > current { return true }
            if new < current { return false }
        }
        return newComponents.count > currentComponents.count
    }
}
