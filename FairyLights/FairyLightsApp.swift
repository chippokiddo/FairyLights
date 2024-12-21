import AppKit
import SwiftUI

@main
struct FairyLightsApp: App {
	@StateObject private var lightsController = LightsController()
	@StateObject private var appState = AppState()
	@StateObject private var windowManager = WindowManager()

	@State private var isCheckingForUpdates = false

	var body: some Scene {
		MenuBarExtra {
			VStack {
				Button(lightsController.isLightsOn ? "Turn Off" : "Turn On") {
					lightsController.toggleLights()
				}
                .keyboardShortcut("L", modifiers: [.command, .option])

				Divider()

				Button("About Fairy Lights") {
					showAboutWindow()
				}

				Button(action: { checkForAppUpdates() }) {
					Text(isCheckingForUpdates ? "Checking..." : "Check for Updates")
				}
				.disabled(isCheckingForUpdates)

				Button("Settings...") {
					showSettingsWindow()
				}
				.keyboardShortcut(",", modifiers: [.command])

				Divider()

				Button("Quit") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("Q", modifiers: [.command])
			}
		} label: {
			Image(nsImage: menuBarIcon())
				.opacity(lightsController.isLightsOn ? 1.0 : 0.35)
		}
        
        // Global commands
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(lightsController.isLightsOn ? "Turn Off Lights" : "Turn On Lights") {
                    lightsController.toggleLights()
                }
                .keyboardShortcut("L", modifiers: [.command, .option])
            }
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
				showAlert(
					title: "Update Check Failed", message: error.localizedDescription, style: .warning)
			}
		}
	}

	private func handleUpdateCheckResult(latestVersion: String, downloadURL: URL) {
		let currentVersion =
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

		if isNewerVersion(latestVersion, than: currentVersion) {
			showAlert(
				title: "New Update Available",
				message: "Fairy Lights \(latestVersion) is available. Would you like to download it?",
				style: .informational,
				buttons: ["Download", "Later"]
			) { response in
				if response == .alertFirstButtonReturn {
					NSWorkspace.shared.open(downloadURL)
				}
			}
		} else {
			showAlert(
				title: "No Updates Available",
				message: "You are already on the latest version.",
				style: .informational)
		}
	}

	// MARK: - Window Management
	private weak var aboutWindow: NSWindow?
	private weak var settingsWindow: NSWindow?

	private func showAboutWindow() {
		if let window = windowManager.aboutWindow {
			window.makeKeyAndOrderFront(nil)
			return
		}
		let hostingController = NSHostingController(rootView: AboutView())
		let window = createWindow(controller: hostingController, title: "About Fairy Lights")
		windowManager.aboutWindow = window
	}

	private func showSettingsWindow() {
		if let window = windowManager.settingsWindow {
			window.makeKeyAndOrderFront(nil)
			return
		}
		let hostingController = NSHostingController(rootView: SettingsView(checkForUpdates: {
			checkForAppUpdates()
		}).environmentObject(appState))
		let window = createWindow(controller: hostingController, title: "Settings")
		windowManager.settingsWindow = window
	}

	private func createWindow(controller: NSHostingController<some View>, title: String) -> NSWindow {
		let window = NSWindow(contentViewController: controller)
		window.isReleasedWhenClosed = false
		window.center()
		window.title = title
		window.titleVisibility = .hidden
		window.titlebarAppearsTransparent = true
		window.setContentSize(controller.view.intrinsicContentSize)
		window.styleMask.remove(.resizable)
		window.styleMask.remove(.miniaturizable)
		window.makeKeyAndOrderFront(nil)
		return window
	}


	// MARK: - Alert Handling
	private func showAlert(
		title: String, message: String, style: NSAlert.Style, buttons: [String] = ["OK"],
		completion: ((NSApplication.ModalResponse) -> Void)? = nil
	) {
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
