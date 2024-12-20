import SwiftUI
import AppKit

@main
struct FairyLightsApp: App {
    @StateObject private var lightsController = LightsController()
    @StateObject private var appState = AppState()
    
    @State private var windows: [String: NSWindow] = [:]
    @State private var isCheckingForUpdates = false
    
    var body: some Scene {
        MenuBarExtra {
            VStack {
                Button(lightsController.isLightsOn ? "Turn Off" : "Turn On") {
                    lightsController.toggleLights()
                }
                Divider()
                Button("About Fairy Lights") { showWindow(id: "about", view: AboutView(), title: "About Fairy Lights", width: 320, height: 320) }
                Button("Check for Updates") { checkForAppUpdates() }
                Button("Settings...") { showWindow(id: "settings", view: SettingsView(checkForUpdates: { checkForAppUpdates()
                })
                    .environmentObject(appState), title: "Settings...", width: 400, height: 250) }
                    .keyboardShortcut(",", modifiers: [.command])
                Divider()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
        } label: {
            Image(nsImage: menuBarIcon())
                .opacity(lightsController.isLightsOn ? 1.0 : 0.35)
        }
    }
    
    // MARK: - Update Check
    private func checkForAppUpdates() {
        guard !isCheckingForUpdates else { return }
        isCheckingForUpdates = true
        Task { @MainActor in
            defer { isCheckingForUpdates = false }
            do {
                let (latestVersion, downloadURL) = try await fetchLatestRelease()
                handleUpdateCheckResult(latestVersion: latestVersion, downloadURL: downloadURL)
            } catch {
                showAlert(title: "Update Check Failed", message: error.localizedDescription, style: .warning)
            }
        }
    }
    
    private func handleUpdateCheckResult(latestVersion: String, downloadURL: URL) {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        
        if isNewerVersion(latestVersion, than: currentVersion) {
            showAlert(title: "New Update Available",
                      message: "Fairy Lights \(latestVersion) is available. Would you like to download it?",
                      style: .informational,
                      buttons: ["Download", "Later"]) { response in
                if response == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(downloadURL)
                }
            }
        } else {
            showAlert(title: "No Updates Available",
                      message: "You are already on the latest version.",
                      style: .informational)
        }
    }
    
    // MARK: - Window Management
    private func showWindow<T: View>(id: String, view: T, title: String, width: CGFloat, height: CGFloat) {
        if windows[id] == nil {
            let hostingController = NSHostingController(rootView: view)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: width, height: height),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = title
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            window.center()
            windows[id] = window
        }
        windows[id]?.makeKeyAndOrderFront(nil)
    }
    
    // MARK: - Alert Handling
    private func showAlert(title: String, message: String, style: NSAlert.Style, buttons: [String] = ["OK"], completion: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        buttons.forEach { alert.addButton(withTitle: $0) }
        let response = alert.runModal()
        completion?(response)
    }
    
    // MARK: - Helper Functions
    private func menuBarIcon() -> NSImage {
        let image = NSImage(named: "MenuBarIcon") ?? NSImage()
        let ratio = image.size.height / image.size.width
        image.size.height = 16
        image.size.width = 16 / ratio
        return image
    }
    
    private func isNewerVersion(_ newVersion: String, than currentVersion: String) -> Bool {
        let parse = { (version: String) in version.split(separator: ".").compactMap { Int($0) } }
        let newComponents = parse(newVersion)
        let currentComponents = parse(currentVersion)
        
        for (new, current) in zip(newComponents, currentComponents) {
            if new != current { return new > current }
        }
        return newComponents.count > currentComponents.count
    }
}
